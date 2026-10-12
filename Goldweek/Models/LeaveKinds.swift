//
//  LeaveKinds.swift
//  Goldweek
//
//  직접 만드는 휴가 종류와 휴가 색 — 달력에서 종류마다 다른 색으로 보이게 한다
//  (이탈리아 사용자 피드백: permessi 를 종류별로 만들고 색을 정하고 싶다)
//

import SwiftUI
import SwiftData
import LeeoKit

/// 사용자가 만든 휴가 종류 (예: "ROL", "Permesso studio") — 이름·색·연차 차감 여부
@Model
final class CustomLeaveType {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "4FACFE"
    /// 연차에서 빼는지 — 기록의 typeRaw 를 .annual / .special 로 맞춰 기존 계산이 그대로 돈다
    var deductsFromAnnual: Bool = true
    var createdAt: Date = Date()
    /// 1년에 쓸 수 있는 양 (이탈리아 permessi 의 "monte ore") — 0 이면 한도 없음.
    /// allowanceIsHours 면 시간, 아니면 일. 해마다(연차 기준월) 새로 센다.
    var allowanceAmount: Double = 0
    var allowanceIsHours: Bool = true

    init(name: String, colorHex: String, deductsFromAnnual: Bool) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.deductsFromAnnual = deductsFromAnnual
        self.createdAt = Date()
    }

    var color: Color { Color(hex: colorHex) ?? AppTheme.Colors.leave }

    /// 이 종류로 기록할 때 저장할 기본 유형 — 차감 계산은 이 값이 맡는다
    var baseType: LeaveType { deductsFromAnnual ? .annual : .special }

    var hasAllowance: Bool { allowanceAmount > 0 }
}

/// 휴가 종류 하나 — 기본 종류(연차·병가 등) 또는 직접 만든 종류. 순서·통계에서 둘을 함께 다룬다.
enum LeaveKindRef: Hashable, Identifiable {
    case builtIn(LeaveType)
    case custom(UUID)

    var id: String { key }

    /// 순서 저장용 키
    var key: String {
        switch self {
        case .builtIn(let t): return "b:\(t.rawValue)"
        case .custom(let id): return "c:\(id.uuidString)"
        }
    }

    init?(key: String) {
        if key.hasPrefix("b:"), let t = LeaveType(rawValue: String(key.dropFirst(2))) {
            self = .builtIn(t)
        } else if key.hasPrefix("c:"), let id = UUID(uuidString: String(key.dropFirst(2))) {
            self = .custom(id)
        } else {
            return nil
        }
    }

    /// 기록이 속한 종류 — 직접 만든 종류가 지워졌으면 기본 종류로 본다
    init(record: LeaveRecord, existingCustom: Set<UUID>) {
        if let id = record.customTypeId, existingCustom.contains(id) {
            self = .custom(id)
        } else {
            self = .builtIn(record.category)
        }
    }
}

/// 휴가 종류별 이름·색의 거울 — 달력 칸처럼 @Query 를 못 쓰는 곳에서도 같은 값을 읽는다.
/// 원본은 SwiftData(CustomLeaveType)와 UserDefaults(기본 종류 색)이고, ContentView 가 맞춰 둔다.
@Observable
final class LeaveStyleStore {
    static let shared = LeaveStyleStore()

    struct Kind: Equatable {
        let name: String
        let colorHex: String
    }

    /// 직접 만든 종류 (id → 이름·색)
    private(set) var customKinds: [UUID: Kind] = [:]
    /// 기본 종류의 색 바꿈 (typeRaw → hex). 없으면 기본 휴가색.
    private(set) var builtInColorHex: [String: String] = [:]

    private static let colorsKey = "leaveTypeColors"
    private static let orderKey = "leaveKindOrder"

    /// 사용자가 정한 종류 순서 (LeaveKindRef.key). 여기 없는 종류는 기본 순서대로 뒤에 붙는다.
    private(set) var orderKeys: [String] = []

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.colorsKey),
           let map = try? JSONDecoder().decode([String: String].self, from: data) {
            builtInColorHex = map
        }
        orderKeys = UserDefaults.standard.stringArray(forKey: Self.orderKey) ?? []
    }

    /// 다른 기기에서 iCloud 로 바뀐 값을 다시 읽는다 (`LeaveSettingsSync`)
    func reloadFromDefaults() {
        if let data = UserDefaults.standard.data(forKey: Self.colorsKey),
           let map = try? JSONDecoder().decode([String: String].self, from: data) {
            if map != builtInColorHex { builtInColorHex = map }
        } else if !builtInColorHex.isEmpty {
            builtInColorHex = [:]
        }
        let order = UserDefaults.standard.stringArray(forKey: Self.orderKey) ?? []
        if order != orderKeys { orderKeys = order }
    }

    /// 모든 종류를 사용자 순서로 — 기본 종류 먼저, 직접 만든 종류는 만든 순서가 기본
    func orderedKinds(custom: [CustomLeaveType]) -> [LeaveKindRef] {
        let defaults = LeaveType.categories.map { LeaveKindRef.builtIn($0) }
            + custom.sorted { $0.createdAt < $1.createdAt }.map { LeaveKindRef.custom($0.id) }
        let available = Set(defaults)
        var result: [LeaveKindRef] = []
        for key in orderKeys {
            if let ref = LeaveKindRef(key: key), available.contains(ref), !result.contains(ref) { result.append(ref) }
        }
        for ref in defaults where !result.contains(ref) { result.append(ref) }
        return result
    }

    /// 순서 바꾸기 — 화면에 보이는 전체 순서를 그대로 저장한다
    func setOrder(_ kinds: [LeaveKindRef]) {
        orderKeys = kinds.map(\.key)
        UserDefaults.standard.set(orderKeys, forKey: Self.orderKey)
    }

    func update(customTypes: [CustomLeaveType]) {
        let kinds = Dictionary(customTypes.map { ($0.id, Kind(name: $0.name, colorHex: $0.colorHex)) },
                               uniquingKeysWith: { a, _ in a })
        if kinds != customKinds { customKinds = kinds }
    }

    /// 기본 종류의 색 — 바꾼 적 없으면 기본 휴가색
    func color(for type: LeaveType) -> Color {
        builtInColorHex[type.rawValue].flatMap { Color(hex: $0) } ?? AppTheme.Colors.leave
    }

    func hasCustomColor(for type: LeaveType) -> Bool { builtInColorHex[type.rawValue] != nil }

    /// 기본 종류 색 바꾸기 — nil 이면 기본 휴가색으로 되돌린다
    func setColor(_ hex: String?, for type: LeaveType) {
        builtInColorHex[type.rawValue] = hex
        if let data = try? JSONEncoder().encode(builtInColorHex) {
            UserDefaults.standard.set(data, forKey: Self.colorsKey)
        }
    }

    /// 백업 복원용 — 기본 종류 색을 통째로 바꾼다
    func replaceBuiltInColors(_ map: [String: String]) {
        builtInColorHex = [:]
        map.forEach { setColor($0.value, for: LeaveType(rawValue: $0.key) ?? .annual) }
    }

    /// 달력에 칠할 기록의 색
    func color(for record: LeaveRecord) -> Color {
        if let id = record.customTypeId, let kind = customKinds[id] {
            return Color(hex: kind.colorHex) ?? AppTheme.Colors.leave
        }
        return color(for: record.category)
    }

    /// 기록의 종류 이름 — 직접 만든 종류면 그 이름
    func name(for record: LeaveRecord) -> String {
        if let id = record.customTypeId, let kind = customKinds[id] { return kind.name }
        return Strings.leaveTypeName(record.category)
    }
}

extension LeaveRecord {
    /// 목록·달력에 보일 종류 이름 (직접 만든 종류 반영)
    var displayTypeName: String { LeaveStyleStore.shared.name(for: self) }
    /// 달력에 칠할 색 (직접 만든 종류·바꾼 색 반영)
    var displayColor: Color { LeaveStyleStore.shared.color(for: self) }

    /// 길이 이름 — 시간 단위면 "2시간 30분" 처럼 실제 길이
    var lengthLabel: String {
        length == .hours ? Strings.durationText(minutes: durationMinutes ?? 0) : Strings.leaveLengthName(length)
    }
}

extension Color {
    /// "RRGGBB" — ColorPicker 의 넓은 색 공간 값도 0~255 로 잘라 저장한다
    var leaveHex: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        func byte(_ v: CGFloat) -> Int { Int((min(max(v, 0), 1) * 255).rounded()) }
        return String(format: "%02X%02X%02X", byte(r), byte(g), byte(b))
    }
}

// MARK: - 종류별 사용량 (통계 · 연간 한도 카운터)

/// 한 해 동안 휴가 종류 하나를 얼마나 썼는지 — 일수와 시간(분)을 함께 센다.
/// 취소는 세지 않고, 끝난 예정 휴가는 사용으로 본다 (`LeaveUsageCalculator` 와 같은 규칙).
struct LeaveKindUsage: Equatable {
    var usedDays: Double = 0
    var plannedDays: Double = 0
    var usedMinutes: Int = 0
    var plannedMinutes: Int = 0
    var usedCount = 0
    var plannedCount = 0
    /// 시간 단위로 쓴 기록이 있는지 — 한도가 없을 때 시간으로 보여 줄지 정한다
    var hasHourRecords = false

    var totalCount: Int { usedCount + plannedCount }

    /// 한 해, 종류별 사용량
    static func byKind(records: [LeaveRecord], customTypes: [CustomLeaveType], year: Int, startMonth: Int,
                       asOf now: Date = Date(), calendar: Calendar = .current) -> [LeaveKindRef: LeaveKindUsage] {
        let existing = Set(customTypes.map(\.id))
        var result: [LeaveKindRef: LeaveKindUsage] = [:]
        for r in LeaveUsageCalculator.records(records, inFiscalYear: year, startMonth: startMonth, calendar: calendar)
        where r.status != .cancelled {
            let ref = LeaveKindRef(record: r, existingCustom: existing)
            var u = result[ref] ?? LeaveKindUsage()
            let days = r.effectiveLeaveDays
            let minutes = workMinutes(of: r, calendar: calendar)
            if LeaveUsageCalculator.isCompleted(r, asOf: now, calendar: calendar) {
                u.usedDays += days; u.usedMinutes += minutes; u.usedCount += 1
            } else {
                u.plannedDays += days; u.plannedMinutes += minutes; u.plannedCount += 1
            }
            if r.length == .hours { u.hasHourRecords = true }
            result[ref] = u
        }
        return result
    }

    /// 기록이 쓴 근무 시간(분) — 종일은 그 기간 근무일마다 그 요일의 근무 시간을 더한다
    static func workMinutes(of record: LeaveRecord, calendar: Calendar = .current) -> Int {
        if record.length == .full, record.isBulkSummary { return record.daysCount * LeaveLength.workdayMinutes }
        return workMinutes(length: record.length, durationMinutes: record.durationMinutes,
                           start: record.startDate, end: record.endDate, calendar: calendar)
    }

    /// 저장 전 입력값으로도 같은 계산 (휴가 등록 화면의 한도 안내)
    static func workMinutes(length: LeaveLength, durationMinutes: Int?, start: Date, end: Date,
                            calendar: Calendar = .current) -> Int {
        switch length {
        case .hours:
            return max(0, durationMinutes ?? 0)
        case .half, .quarter:
            return Int((Double(LeaveLength.workdayMinutes(on: start, calendar: calendar)) * length.fraction).rounded())
        case .full:
            var total = 0
            var day = calendar.startOfDay(for: start)
            let last = calendar.startOfDay(for: end)
            while day <= last {
                if !DayOffCalendar.shared.isDayOff(day) { total += LeaveLength.workdayMinutes(on: day, calendar: calendar) }
                guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
                day = next
            }
            return total
        }
    }
}

/// 연간 한도가 있는 종류의 카운터 — 사용 · 예정 · 남음 (한도의 단위로)
struct LeaveAllowanceCounter: Equatable {
    let isHours: Bool
    /// 한도 / 사용 / 예정 — 시간이면 분, 일이면 일
    let total: Double
    let used: Double
    let planned: Double

    var remaining: Double { total - used - planned }
    var isOver: Bool { remaining < -0.0001 }

    init(kind: CustomLeaveType, usage: LeaveKindUsage) {
        isHours = kind.allowanceIsHours
        total = kind.allowanceIsHours ? kind.allowanceAmount * 60 : kind.allowanceAmount
        used = kind.allowanceIsHours ? Double(usage.usedMinutes) : usage.usedDays
        planned = kind.allowanceIsHours ? Double(usage.plannedMinutes) : usage.plannedDays
    }

    /// 화면에 보일 양 — 시간이면 "7시간 30분", 일이면 "2.5일"
    /// 넘게 쓴 경우(음수)는 앞에 "−"
    func text(_ value: Double) -> String {
        let sign = value < -0.0001 ? "−" : ""
        let v = abs(value)
        return sign + (isHours ? Strings.durationText(minutes: Int(v.rounded())) : Strings.dayCount(v))
    }
}

// MARK: - 휴가 종류·근무 시간 설정 iCloud 동기화

/// 휴가 종류 색·순서, 하루 근무 시간, 요일별 근무 시간을 iCloud 키값 저장소로 기기끼리 맞춘다.
/// 휴가 기록 자체는 동기화하지 않는다 (iCloud 백업·복원이 맡는다) — 작은 설정값만.
///
/// - 앱을 켤 때: iCloud 에 값이 있으면 그 값을 쓰고, 없으면 이 기기 값을 올린다 (새 기기는 바로 같은 설정)
/// - 이 기기에서 바꾸면: UserDefaults 변경을 보고 다른 값만 올린다
/// - 다른 기기에서 바뀌면: 내려받아 UserDefaults 에 쓰고 화면을 다시 그린다 (같은 값이라 다시 올리지 않는다)
final class LeaveSettingsSync {
    static let shared = LeaveSettingsSync()

    static let keys = ["leaveTypeColors", "leaveKindOrder", "workdayMinutes", "workdayMinutesByWeekday"]

    private let cloud = NSUbiquitousKeyValueStore.default
    private let defaults = UserDefaults.standard
    private var started = false
    private var isApplyingCloud = false

    private init() {}

    func start() {
        guard !started else { return }
        started = true
        NotificationCenter.default.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: cloud, queue: .main) { [weak self] note in
            let changed = note.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? Self.keys
            self?.pull(keys: changed.filter { Self.keys.contains($0) })
        }
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification,
                                               object: defaults, queue: .main) { [weak self] _ in
            self?.pushChanges()
        }
        cloud.synchronize()
        // iCloud 에 있는 값이 먼저, 없는 키만 이 기기 값으로 채운다
        pull(keys: Self.keys.filter { cloud.object(forKey: $0) != nil })
        pushChanges()
    }

    private func pull(keys: [String]) {
        guard !keys.isEmpty else { return }
        isApplyingCloud = true
        defer { isApplyingCloud = false }
        var changed = false
        for key in keys {
            let value = cloud.object(forKey: key)
            guard !Self.same(value, defaults.object(forKey: key)) else { continue }
            if let value { defaults.set(value, forKey: key) } else { defaults.removeObject(forKey: key) }
            changed = true
        }
        guard changed else { return }
        LeaveStyleStore.shared.reloadFromDefaults()
        logInfo("iCloud 에서 휴가 설정 받음: \(keys.joined(separator: ","))", category: .iCloud)
    }

    private func pushChanges() {
        guard !isApplyingCloud else { return }
        var changed = false
        for key in Self.keys {
            let local = defaults.object(forKey: key)
            guard !Self.same(local, cloud.object(forKey: key)) else { continue }
            if let local { cloud.set(local, forKey: key) } else { cloud.removeObject(forKey: key) }
            changed = true
        }
        if changed { cloud.synchronize() }
    }

    private static func same(_ a: Any?, _ b: Any?) -> Bool {
        switch (a, b) {
        case (nil, nil): return true
        case let (a as NSObject, b as NSObject): return a.isEqual(b)
        default: return false
        }
    }
}
