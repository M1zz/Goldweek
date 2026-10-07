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

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.colorsKey),
           let map = try? JSONDecoder().decode([String: String].self, from: data) {
            builtInColorHex = map
        }
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
