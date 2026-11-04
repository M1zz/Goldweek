//
//  AddLeaveView.swift
//  Goldweek
//
//  연차 등록 및 보너스 연차 관리 화면
//

import SwiftUI
import SwiftData
import StoreKit   // @Environment(\.requestReview) 의 RequestReviewAction

struct AddLeaveView: View {
    @Bindable var profile: UserProfile
    var initialDate: Date? = nil
    /// 빠른 넣기에서 고른 끝나는 날 — "반차 · 종류 · 메모"로 넘어올 때 기간을 그대로 잇는다
    var initialEndDate: Date? = nil
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \LeaveRecord.startDate, order: .reverse) private var leaveRecords: [LeaveRecord]
    @Query(sort: \BonusLeave.grantedDate, order: .reverse) private var bonusLeaves: [BonusLeave]

    @State private var selectedTab = 0

    /// 계산은 `LeaveUsageCalculator` 한 곳에서 (회계연도 기준도 여기서 맞춰진다)
    var committedLeave: Double {
        LeaveUsageCalculator.currentSummary(records: Array(leaveRecords),
                                            startMonth: profile.yearStart).annualCommitted
    }

    /// 올해 남은 연차 (지난해에서 넘어온 몫 포함)
    var remainingAnnualLeave: Double {
        LeaveUsageCalculator.currentSummary(records: Array(leaveRecords), startMonth: profile.yearStart,
                                            annualGrant: profile.totalAnnualLeave)
            .remaining(annualGrant: profile.totalAnnualLeave, includingBonus: false)
    }

    var totalBonusLeave: Double {
        let now = Date()
        let available = bonusLeaves.filter { !$0.isUsed }
        let notExpired = available.filter { $0.expirationDate == nil || $0.expirationDate! > now }
        return notExpired.reduce(0.0) { $0 + $1.remainingDays }
    }

    var totalAvailableLeave: Double {
        remainingAnnualLeave + totalBonusLeave
    }

    private var isLeisure: Bool { profile.userType == .leisure }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 현황 요약 헤더
                if isLeisure {
                    LeisureStatusHeader(
                        usedDays: committedLeave,
                        goalDays: profile.totalAnnualLeave
                    )
                } else {
                    LeaveStatusHeader(
                        remainingLeave: remainingAnnualLeave,
                        bonusLeave: totalBonusLeave,
                        totalAvailable: totalAvailableLeave
                    )
                }

                // 탭 선택 — 직장인 모드만 보너스 탭 노출
                if !isLeisure, AppSurface.shared.shows(.leaveKinds) {
                    Picker(Strings.managementType, selection: $selectedTab) {
                        Text(Strings.registerLeave).tag(0)
                        Text(Strings.addLeave).tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .onChange(of: selectedTab) { _, _ in
                        HapticFeedback.selection()
                    }
                }

                if selectedTab == 0 || isLeisure {
                    LeaveRegistrationView(
                        profile: profile,
                        totalAvailableLeave: totalAvailableLeave,
                        leaveRecords: Array(leaveRecords.prefix(5)),
                        initialDate: initialDate,
                        initialEndDate: initialEndDate
                    )
                } else {
                    BonusLeaveView(bonusLeaves: bonusLeaves)
                }
            }
            .navigationTitle(isLeisure ? Strings.registerLeave : Strings.navTitleLeaveManagement)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.close) { dismiss() }
                }
            }
        }
    }
}

// MARK: - 자유 계획 현황 헤더
struct LeisureStatusHeader: View {
    let usedDays: Double
    let goalDays: Double

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Strings.statUsed)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Text("\(Strings.dayCount(usedDays))")
                    .font(.title3.bold())
                    .foregroundStyle(.blue)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(goalDays > 0 ? Strings.leisureGoalRemaining : Strings.leisureTotalPlan)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Text(goalDays > 0 ? "\(Strings.dayCount(max(0, goalDays - usedDays)))" : "\(Strings.dayCount(usedDays))")
                    .font(.title2.bold())
                    .foregroundStyle(.purple)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .voCard(VoiceOverLabel.leaveBalance(total: goalDays, used: usedDays, remaining: max(0, goalDays - usedDays)))
    }
}

// MARK: - 연차 현황 헤더
struct LeaveStatusHeader: View {
    let remainingLeave: Double
    let bonusLeave: Double
    let totalAvailable: Double

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private func formatD(_ v: Double) -> String {
        v == v.rounded() ? "\(Int(v))" : String(format: "%.1f", v)
    }

    private var voLabel: String {
        let lang = LanguageManager.shared.currentLanguage
        if bonusLeave > 0 {
            switch lang {
            case .korean: return "\(Strings.basicLeave) \(formatD(remainingLeave))일, \(Strings.bonus) \(formatD(bonusLeave))일, \(Strings.totalAvailable) \(formatD(totalAvailable))일"
            case .english: return "\(Strings.basicLeave) \(formatD(remainingLeave)) days, \(Strings.bonus) \(formatD(bonusLeave)) days, \(Strings.totalAvailable) \(formatD(totalAvailable)) days"
            case .swedish: return "\(Strings.basicLeave) \(formatD(remainingLeave)) dagar, \(Strings.bonus) \(formatD(bonusLeave)) dagar, \(Strings.totalAvailable) \(formatD(totalAvailable)) dagar"
            case .norwegian: return "\(Strings.basicLeave) \(formatD(remainingLeave)) dager, \(Strings.bonus) \(formatD(bonusLeave)) dager, \(Strings.totalAvailable) \(formatD(totalAvailable)) dager"
            case .danish: return "\(Strings.basicLeave) \(formatD(remainingLeave)) dage, \(Strings.bonus) \(formatD(bonusLeave)) dage, \(Strings.totalAvailable) \(formatD(totalAvailable)) dage"
            case .finnish: return "\(Strings.basicLeave) \(formatD(remainingLeave)) päivää, \(Strings.bonus) \(formatD(bonusLeave)) päivää, \(Strings.totalAvailable) \(formatD(totalAvailable)) päivää"
            case .polish: return "\(Strings.basicLeave) \(formatD(remainingLeave)) dni, \(Strings.bonus) \(formatD(bonusLeave)) dni, \(Strings.totalAvailable) \(formatD(totalAvailable)) dni"
            case .czech: return "\(Strings.basicLeave) \(formatD(remainingLeave)) d, \(Strings.bonus) \(formatD(bonusLeave)) d, \(Strings.totalAvailable) \(formatD(totalAvailable)) d"
            case .greek: return "\(Strings.basicLeave) \(formatD(remainingLeave)) ημέρες, \(Strings.bonus) \(formatD(bonusLeave)) ημέρες, \(Strings.totalAvailable) \(formatD(totalAvailable)) ημέρες"
            case .turkish: return "\(Strings.basicLeave) \(formatD(remainingLeave)) gün, \(Strings.bonus) \(formatD(bonusLeave)) gün, \(Strings.totalAvailable) \(formatD(totalAvailable)) gün"
            case .russian: return "\(Strings.basicLeave) \(formatD(remainingLeave)) \(ruPlural(remainingLeave, "день", "дня", "дней")), \(Strings.bonus) \(formatD(bonusLeave)) \(ruPlural(bonusLeave, "день", "дня", "дней")), \(Strings.totalAvailable) \(formatD(totalAvailable)) \(ruPlural(totalAvailable, "день", "дня", "дней"))"
            case .indonesian: return "\(Strings.basicLeave) \(formatD(remainingLeave)) hari, \(Strings.bonus) \(formatD(bonusLeave)) hari, \(Strings.totalAvailable) \(formatD(totalAvailable)) hari"
            case .thai: return "\(Strings.basicLeave) \(formatD(remainingLeave)) วัน, \(Strings.bonus) \(formatD(bonusLeave)) วัน, \(Strings.totalAvailable) \(formatD(totalAvailable)) วัน"
            case .vietnamese: return "\(Strings.basicLeave) \(formatD(remainingLeave)) ngày, \(Strings.bonus) \(formatD(bonusLeave)) ngày, \(Strings.totalAvailable) \(formatD(totalAvailable)) ngày"
            case .dutch: return "\(Strings.basicLeave) \(formatD(remainingLeave)) dagen, \(Strings.bonus) \(formatD(bonusLeave)) dagen, \(Strings.totalAvailable) \(formatD(totalAvailable)) dagen"
            case .japanese: return "\(Strings.basicLeave) \(formatD(remainingLeave))日、\(Strings.bonus) \(formatD(bonusLeave))日、\(Strings.totalAvailable) \(formatD(totalAvailable))日"
            case .chinese: return "\(Strings.basicLeave) \(formatD(remainingLeave))天，\(Strings.bonus) \(formatD(bonusLeave))天，\(Strings.totalAvailable) \(formatD(totalAvailable))天"
            case .german: return "\(Strings.basicLeave) \(formatD(remainingLeave)) Tage, \(Strings.bonus) \(formatD(bonusLeave)) Tage, \(Strings.totalAvailable) \(formatD(totalAvailable)) Tage"
            case .french: return "\(Strings.basicLeave) \(formatD(remainingLeave)) jours, \(Strings.bonus) \(formatD(bonusLeave)) jours, \(Strings.totalAvailable) \(formatD(totalAvailable)) jours"
            case .spanish: return "\(Strings.basicLeave) \(formatD(remainingLeave)) días, \(Strings.bonus) \(formatD(bonusLeave)) días, \(Strings.totalAvailable) \(formatD(totalAvailable)) días"
            case .italian: return "\(Strings.basicLeave) \(formatD(remainingLeave)) giorni, \(Strings.bonus) \(formatD(bonusLeave)) giorni, \(Strings.totalAvailable) \(formatD(totalAvailable)) giorni"
            case .portuguese: return "\(Strings.basicLeave) \(formatD(remainingLeave)) dias, \(Strings.bonus) \(formatD(bonusLeave)) dias, \(Strings.totalAvailable) \(formatD(totalAvailable)) dias"
            case .chineseTraditional: return "\(Strings.basicLeave) \(formatD(remainingLeave)) 天，\(Strings.bonus) \(formatD(bonusLeave)) 天，\(Strings.totalAvailable) \(formatD(totalAvailable)) 天"
            }
        } else {
            switch lang {
            case .korean: return "\(Strings.totalAvailable) \(formatD(totalAvailable))일"
            case .english: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) days"
            case .swedish: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) dagar"
            case .norwegian: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) dager"
            case .danish: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) dage"
            case .finnish: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) päivää"
            case .polish: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) dni"
            case .czech: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) d"
            case .greek: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) ημέρες"
            case .turkish: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) gün"
            case .russian: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) \(ruPlural(totalAvailable, "день", "дня", "дней"))"
            case .indonesian: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) hari"
            case .thai: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) วัน"
            case .vietnamese: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) ngày"
            case .dutch: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) dagen"
            case .japanese: return "\(Strings.totalAvailable) \(formatD(totalAvailable))日"
            case .chinese: return "\(Strings.totalAvailable) \(formatD(totalAvailable))天"
            case .german: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) Tage"
            case .french: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) jours"
            case .spanish: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) días"
            case .italian: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) giorni"
            case .portuguese: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) dias"
            case .chineseTraditional: return "\(Strings.totalAvailable) \(formatD(totalAvailable)) 天"
            }
        }
    }

    var body: some View {
        // 아주 큰 글씨에서는 '기본 + 보너스 = 총' 을 가로로 놓으면 화면 밖으로 밀려나므로 세로로 쌓는다
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 16))
        layout {
            if bonusLeave > 0 {
                // 보너스가 있을 때만 "기본 + 보너스 = 총" 분해를 보여준다.
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.basicLeave)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Text("\(Strings.dayCount(remainingLeave))")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.Colors.brand)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }

                Text("+")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.bonus)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Text("\(Strings.dayCount(bonusLeave))")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.Colors.compensatory)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }

                Text("=")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(Strings.totalAvailable)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    Text("\(Strings.dayCount(totalAvailable))")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.Colors.success)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            } else {
                // 보너스가 없으면 기본연차 == 총 사용가능이라 한 번만 보여준다.
                VStack(alignment: .leading, spacing: 4) {
                    Text(Strings.availableLeave)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Text("\(Strings.dayCount(totalAvailable))")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.Colors.success)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .voCard(voLabel)
    }
}

// MARK: - 휴가 등록 뷰
struct LeaveRegistrationView: View {
    @Bindable var profile: UserProfile
    let totalAvailableLeave: Double
    let leaveRecords: [LeaveRecord]
    var initialDate: Date? = nil
    var initialEndDate: Date? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    /// 처음 열 때 시작일을 바꾸면 아래 onChange 가 끝나는 날을 길이만큼 옮긴다 — 그때 받은 끝나는 날을 쓴다
    @State private var pendingInitialEnd: Date?

    @Query private var allLeaveRecords: [LeaveRecord]

    // 사용 가능한 보너스 연차 (미사용 + 미만료)
    @Query(filter: #Predicate<BonusLeave> { $0.isUsed == false })
    private var unusedBonusLeaves: [BonusLeave]

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var category: LeaveType = .annual
    @State private var length: LeaveLength = .full
    /// 시간 단위 휴가의 길이(분)
    @State private var durationMinutes = 120
    /// 직접 만든 휴가 종류 — 고르면 category 는 그 종류의 기본 유형(차감 여부)을 따른다
    @State private var customType: CustomLeaveType?
    @Query(sort: \CustomLeaveType.createdAt) private var customLeaveTypes: [CustomLeaveType]
    @State private var note = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isSaving = false
    @State private var selectedBonusLeave: BonusLeave?
    @FocusState private var isNoteFocused: Bool

    var committedLeave: Double {
        LeaveUsageCalculator.currentSummary(records: Array(allLeaveRecords),
                                            startMonth: profile.yearStart).annualCommitted
    }

    /// 만료되지 않은 보너스 연차
    var availableBonusLeaves: [BonusLeave] {
        let now = Date()
        return unusedBonusLeaves.filter {
            $0.expirationDate == nil || $0.expirationDate! > now
        }
    }

    /// 고른 기간에 휴가 제한일이 있으면 경고 문구 (쉬는 날은 연차가 아니니 보지 않는다)
    /// 내가 넣은 휴가 불가 기간이 걸리면 그 이름을, 아니면 공휴일 앞뒤 제한 문구를 쓴다.
    var blockedWarning: String? {
        let dayOff = DayOffCalendar.shared
        guard dayOff.hasLeaveRestrictions else { return nil }
        let cal = Calendar.app
        var d = cal.startOfDay(for: startDate)
        let end = cal.startOfDay(for: length == .full ? endDate : startDate)
        var nearHoliday = false
        while d <= end {
            if !dayOff.isDayOff(d) {
                if let name = dayOff.blackoutPeriodName(on: d) { return Strings.blackoutPeriodWarning(name) }
                if dayOff.isLeaveBlocked(d) { nearHoliday = true }
            }
            guard let next = cal.date(byAdding: .day, value: 1, to: d) else { break }
            d = next
        }
        return nearHoliday ? Strings.blackoutWarning : nil
    }

    /// 시작~끝 달력 일수
    var calendarDays: Int {
        let cal = Calendar.app
        return (cal.dateComponents([.day], from: cal.startOfDay(for: startDate), to: cal.startOfDay(for: endDate)).day ?? 0) + 1
    }

    /// 차감 일수 — 주말·공휴일·내 방학은 빼고 센다 (LeaveRecord.effectiveLeaveDays 와 같은 기준)
    var leaveDays: Double {
        if length == .hours { return LeaveLength.days(forMinutes: durationMinutes, on: startDate) }
        if length != .full { return length.fraction }
        return Double(DayOffCalendar.shared.workdays(from: startDate, to: endDate))
    }

    /// 고른 시작일이 속한 해에 쓸 수 있는 연차 (넘어온 연차 포함)
    var availableForStartDate: Double {
        LeaveUsageCalculator.availableAnnual(on: startDate, records: Array(allLeaveRecords),
                                             annualGrant: profile.totalAnnualLeave, startMonth: profile.yearStart)
    }

    /// 시작일이 올해가 아닌 해에 속하면 그 해 (예: 10월에 잡는 내년 1월 휴가)
    var futureFiscalYear: Int? {
        let cal = Calendar.app
        let target = LeaveUsageCalculator.fiscalYear(for: startDate, startMonth: profile.yearStart, calendar: cal)
        let now = LeaveUsageCalculator.fiscalYear(for: Date(), startMonth: profile.yearStart, calendar: cal)
        return target > now ? target : nil
    }

    /// 고른 직접 만든 종류에 연간 한도가 있으면, 이번 휴가를 넣은 뒤 그 해에 남는 양
    var allowanceNote: (text: String, isOver: Bool)? {
        guard let kind = customType, kind.hasAllowance, selectedBonusLeave == nil else { return nil }
        let startMonth = profile.yearStart
        let year = LeaveUsageCalculator.fiscalYear(for: startDate, startMonth: startMonth)
        let counter = LeaveAllowanceCounter.make(kind: kind, records: Array(allLeaveRecords), year: year, startMonth: startMonth)
        let end = length == .full ? endDate : startDate
        let thisLeave = kind.allowanceIsHours
            ? Double(LeaveKindUsage.workMinutes(length: length, durationMinutes: durationMinutes, start: startDate, end: end))
            : leaveDays
        let left = counter.remaining - thisLeave
        return left < -0.0001
            ? (Strings.allowanceOverAfterThis(counter.text(-left)), true)
            : (Strings.allowanceAfterThis(counter.text(left)), false)
    }

    /// 고른 종류 이름 — 직접 만든 종류면 그 이름
    private var categoryName: String {
        customType?.name ?? Strings.leaveTypeName(category)
    }

    /// 등록 버튼 동적 라벨 — 선택한 휴가 유형 이름을 반영
    /// 예) 출장 → "출장 등록하기", 보너스 사용 시 → 보너스 유형명 사용
    var registerButtonLabel: String {
        let typeName: String = {
            if let bonus = selectedBonusLeave {
                return Strings.bonusLeaveTypeName(bonus.type)
            }
            return categoryName
        }()
        return Strings.registerLeaveButtonWith(typeName: typeName)
    }

    var canAddLeave: Bool {
        addDisabledReason == nil
    }

    /// 등록 버튼이 비활성일 때 그 이유. nil이면 등록 가능.
    var addDisabledReason: String? {
        guard startDate <= endDate else { return Strings.reasonEndBeforeStart }
        // 보너스 연차 사용 시: 잔여 보너스 초과 불가
        if let bonus = selectedBonusLeave {
            return leaveDays <= bonus.remainingDays ? nil : Strings.insufficientLeave
        }
        // 자유 계획 모드: 한도 없음
        if profile.userType == .leisure { return nil }
        // 직장인: 연차 차감 유형이면 잔여 연차 초과 불가
        // 휴가가 속한 해의 연차로 본다 — 내년 휴가는 내년 연차에서 빠진다 (미리 계획)
        if category.deductsFromAnnual {
            return availableForStartDate >= leaveDays ? nil : Strings.insufficientLeave
        }
        return nil
    }

    var body: some View {
        Form {
            // 보너스 연차 선택 (사용 가능한 경우 최상단 표시)
            if !availableBonusLeaves.isEmpty {
                Section {
                    ForEach(availableBonusLeaves) { bonus in
                        Button {
                            if selectedBonusLeave?.id == bonus.id {
                                selectedBonusLeave = nil
                            } else {
                                selectedBonusLeave = bonus
                                // 보너스는 카테고리와 무관하게 보너스에서 차감 — 길이(length)만 적용
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: bonus.type.icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white : AppTheme.Colors.bonus)
                                    .frame(width: 32)
                                    .voDecorative()

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(Strings.bonusLeaveTypeName(bonus.type))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white : .primary)
                                    HStack(spacing: 4) {
                                        Text(Strings.availableDays(formatLeave(bonus.remainingDays)))
                                            .font(.body)
                                            .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white.opacity(0.85) : .secondary)
                                        if !bonus.reason.isEmpty {
                                            Text("· \(bonus.reason)")
                                                .font(.body)
                                                .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white.opacity(0.85) : .secondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                    if let exp = bonus.expirationDate {
                                        Text(Strings.expiresBy(exp.appMonthDay))
                                            .font(.body)
                                            .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white.opacity(0.7) : AppTheme.Colors.bonus)
                                    }
                                }

                                Spacer()

                                Image(systemName: selectedBonusLeave?.id == bonus.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedBonusLeave?.id == bonus.id ? .white : Color(.systemGray3))
                                    .font(.title3)
                                    .voDecorative()
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(
                            selectedBonusLeave?.id == bonus.id
                                ? AppTheme.Colors.bonus.opacity(0.85)
                                : Color(.systemBackground)
                        )
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(bonusSelectLabel(bonus)))
                        .accessibilityAddTraits(selectedBonusLeave?.id == bonus.id ? .isSelected : [])
                    }
                } header: {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill").foregroundStyle(AppTheme.Colors.bonus)
                        Text(Strings.bonusUseSectionHeader)
                    }
                } footer: {
                    if selectedBonusLeave != nil {
                        Text(Strings.bonusUseFooterSelected)
                    } else {
                        Text(Strings.bonusUseFooterUnselected)
                    }
                }
            }

            // 휴가 = 카테고리 × 길이 — 두 축을 독립적으로 선택
            let isLeisureMode = profile.userType == .leisure
            Section {
                // 1) 길이 (종일/반차/반반차) — 항상 표시
                VStack(alignment: .leading, spacing: 8) {
                    Text(Strings.leaveLengthSectionHeader)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .voHeader()
                    HStack(spacing: 8) {
                        ForEach([LeaveLength.quarter, .half, .full] + (LeaveLength.usesHourlyLeave || length == .hours ? [.hours] : []), id: \.self) { len in
                            Button {
                                HapticFeedback.selection()
                                length = len
                            } label: {
                                VStack(spacing: 3) {
                                    Group {
                                        if len == .hours {
                                            Image(systemName: "hourglass")
                                        } else {
                                            Text(len == .quarter ? "¼" : len == .half ? "½" : "1")
                                        }
                                    }
                                    .font(.system(.title2, design: .rounded, weight: .black))
                                    .voDecorative()
                                    Text(Strings.leaveLengthName(len))
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .cellLabel()
                                    Text(len == .hours ? Strings.hoursLengthHint
                                         : len == .quarter ? "0.25\(Strings.dayUnitSuffix)" : len == .half ? "0.5\(Strings.dayUnitSuffix)" : "1\(Strings.dayUnitSuffix)~")
                                        .font(.body)
                                        .cellLabel()
                                        .opacity(0.8)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(length == len ? AppTheme.Colors.brand : Color(.systemGray5))
                                .foregroundStyle(length == len ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text(len == .hours ? Strings.leaveLengthName(len)
                                                     : "\(Strings.leaveLengthName(len)), \(len == .quarter ? "0.25" : len == .half ? "0.5" : "1")\(Strings.dayUnitSuffix)"))
                            .accessibilityAddTraits(length == len ? .isSelected : [])
                        }
                    }
                }
                .padding(.vertical, 4)

                // 2) 카테고리 (연차·특별휴가·병가 등) — 보너스 미선택 + 직장인 모드에서만
                if selectedBonusLeave == nil && !isLeisureMode {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(Strings.leaveCategorySectionHeader)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .voHeader()
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                            // 기본 종류와 직접 만든 종류(예: ROL, 공부 휴가)를 사용자가 정한 순서로
                            ForEach(LeaveStyleStore.shared.orderedKinds(custom: Array(customLeaveTypes))) { ref in
                                switch ref {
                                case .builtIn(let cat):
                                    Button {
                                        HapticFeedback.selection()
                                        category = cat
                                        customType = nil
                                    } label: {
                                        VStack(spacing: 3) {
                                            Image(systemName: cat.icon)
                                                .font(.body)
                                                .voDecorative()
                                            Text(Strings.leaveTypeName(cat))
                                                .font(.body)
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(customType == nil && category == cat ? cat.themeColor : Color(.systemGray5))
                                        .foregroundStyle(customType == nil && category == cat ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(Text(Strings.leaveTypeName(cat)))
                                    .accessibilityAddTraits(customType == nil && category == cat ? .isSelected : [])
                                case .custom(let id):
                                    if let kind = customLeaveTypes.first(where: { $0.id == id }) {
                                        let isSelected = customType?.id == kind.id
                                        Button {
                                            HapticFeedback.selection()
                                            customType = kind
                                            category = kind.baseType
                                        } label: {
                                            VStack(spacing: 3) {
                                                Circle()
                                                    .fill(isSelected ? Color.white : kind.color)
                                                    .frame(width: 12, height: 12)
                                                    .padding(.vertical, 3)
                                                    .voDecorative()
                                                Text(kind.name)
                                                    .font(.body)
                                                    .fontWeight(.semibold)
                                                    .cellLabel()
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(isSelected ? kind.color : Color(.systemGray5))
                                            .foregroundStyle(isSelected ? .white : .primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel(Text(kind.name))
                                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                                    }
                                }
                            }
                            // 종류 만들기·색 바꾸기
                            if AppSurface.shared.shows(.leaveKinds) {
                            NavigationLink {
                                LeaveKindsView()
                            } label: {
                                VStack(spacing: 3) {
                                    Image(systemName: "plus")
                                        .font(.body)
                                        .voDecorative()
                                    Text(Strings.addLeaveKind)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .cellLabel()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .foregroundStyle(AppTheme.Colors.brand)
                                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(AppTheme.Colors.brand.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
                            }
                            .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text(Strings.leaveTypeSection)
            } footer: {
                if selectedBonusLeave == nil && !category.deductsFromAnnual {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text(Strings.noDeductionInfo(categoryName))
                    }
                }
            }

            // 날짜 선택
            Section(Strings.dateSelection) {
                DatePicker(Strings.startDate, selection: $startDate, displayedComponents: .date)

                if length == .full {
                    DatePicker(Strings.endDate, selection: $endDate, in: startDate..., displayedComponents: .date)
                }

                // 시간 단위 — 몇 시간 몇 분 쉬는지
                if length == .hours {
                    Stepper(value: hoursBinding, in: 0...12) {
                        HStack {
                            Text(Strings.leaveHoursLabel)
                            Spacer()
                            Text("\(durationMinutes / 60)")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                    }
                    Stepper(value: minutesBinding, in: 0...55, step: 5) {
                        HStack {
                            Text(Strings.leaveMinutesLabel)
                            Spacer()
                            Text("\(durationMinutes % 60)")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text(Strings.hoursLeaveFooter(workday: Strings.durationText(minutes: LeaveLength.workdayMinutes(on: startDate))))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack {
                    Text(Strings.daysUsed)
                    Spacer()
                    HStack(spacing: 4) {
                        Text(length == .hours ? Strings.durationText(minutes: durationMinutes) : Strings.leaveLengthName(length))
                            .font(.body)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.Colors.brand.opacity(0.15))
                            .foregroundStyle(AppTheme.Colors.brand)
                            .clipShape(Capsule())
                        Text("\(String(format: leaveDays == Double(Int(leaveDays)) ? "%.0f" : "%.2g", leaveDays))\(Strings.dayUnitSuffix)")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                }

                // 내년 휴가를 미리 잡는 중이면 어느 해 연차에서 빠지는지 알린다
                if let year = futureFiscalYear, profile.userType != .leisure, category.deductsFromAnnual, selectedBonusLeave == nil {
                    Label(Strings.futureYearLeaveNote(year: year, remaining: Strings.dayCount(availableForStartDate)),
                          systemImage: "calendar.badge.plus")
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.brand)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // 연간 한도가 있는 종류(이탈리아 permessi 의 monte ore)면 등록 후 남는 양 — 넘어도 막지는 않는다
                if let note = allowanceNote {
                    Label(note.text, systemImage: note.isOver ? "exclamationmark.triangle.fill" : "gauge.with.dots.needle.33percent")
                        .font(.body)
                        .foregroundStyle(note.isOver ? .orange : AppTheme.Colors.brand)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // 직장 규정상 휴가를 못 내는 날이 끼어 있으면 알린다 (막지는 않는다 — 예외 승인이 있을 수 있다)
                if let warning = blockedWarning {
                    Label(warning, systemImage: "exclamationmark.triangle.fill")
                        .font(.body)
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // 달력 일수와 차감 일수가 다르면 왜 다른지 보여 준다 (근무일 기준)
                if length == .full, calendarDays > Int(leaveDays) {
                    Text(Strings.leaveCountingDetail(calendarDays: calendarDays, deducted: Strings.dayCount(leaveDays)))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if startDate < Calendar.app.startOfDay(for: Date()) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.body)
                        Text(Strings.pastLeaveAutoUsed)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // 메모
            Section(Strings.memoOptional) {
                TextField(Strings.memoPlaceholder, text: $note)
                    .focused($isNoteFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isNoteFocused = false
                    }
            }

            // 등록 버튼 — 선택한 유형에 맞춰 동적 라벨
            Section {
                Button(action: addLeave) {
                    HStack {
                        Spacer()
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "plus.circle.fill")
                            Text(registerButtonLabel)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(!canAddLeave || isSaving)
                .foregroundStyle(canAddLeave ? .white : .gray)
                .listRowBackground(canAddLeave ? AppTheme.Colors.brand : Color.gray.opacity(0.3))
            } footer: {
                // 비활성 사유를 버튼 바로 아래에 보여준다
                if let reason = addDisabledReason {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                            .voDecorative()
                        Text(reason)
                    }
                }
            }

            // 최근 등록 내역
            if !leaveRecords.isEmpty {
                Section(Strings.recentRecords) {
                    ForEach(leaveRecords) { record in
                        LeaveRecordRow(record: record)
                    }
                }
            }
        }
        .onChange(of: startDate) { oldStart, newStart in
            let calendar = Calendar.app
            if let end = pendingInitialEnd {
                pendingInitialEnd = nil
                endDate = max(end, newStart)
                return
            }
            if length != .full {
                endDate = newStart
            } else {
                let duration = calendar.dateComponents([.day], from: oldStart, to: endDate).day ?? 0
                endDate = calendar.date(byAdding: .day, value: max(duration, 0), to: newStart) ?? newStart
            }
        }
        .onChange(of: length) { _, newValue in
            if newValue != .full {
                endDate = startDate
            }
        }
        .onAppear {
            if let date = initialDate {
                let end = max(initialEndDate ?? date, date)
                if startDate != date { pendingInitialEnd = end }
                startDate = date
                endDate = end
            }
        }
        .alert(Strings.alert, isPresented: $showingAlert) {
            Button(Strings.confirm, role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        // ⚠️ 여기서 별점 프롬프트를 직접 띄우지 않는다. 자동 리뷰 요청은 만족도 프롬프트
        //    (`ContentView`의 `.leeoSatisfactionCheck`)가 맡는다 — 먼저 물어보고 아쉬운
        //    사람은 피드백으로 보내기 위해서다. 둘 다 두면 한 세션에 두 번 뜬다.
        //    등록 횟수는 계속 세 둔다(구매 후 요청 조건이 참조).
    }

    /// 시간 스테퍼 — 0시간이면 분이 최소 5분은 되게 한다
    private var hoursBinding: Binding<Int> {
        Binding(get: { durationMinutes / 60 },
                set: { durationMinutes = max(5, $0 * 60 + durationMinutes % 60) })
    }

    private var minutesBinding: Binding<Int> {
        Binding(get: { durationMinutes % 60 },
                set: { durationMinutes = max(5, (durationMinutes / 60) * 60 + $0) })
    }

    /// 보너스 선택 버튼을 한 문장으로 읽어주는 VoiceOver 라벨
    private func bonusSelectLabel(_ bonus: BonusLeave) -> String {
        var parts = [
            Strings.bonusLeaveTypeName(bonus.type),
            Strings.availableDays(formatLeave(bonus.remainingDays))
        ]
        if !bonus.reason.isEmpty { parts.append(bonus.reason) }
        if let exp = bonus.expirationDate {
            parts.append(Strings.expiresBy(exp.appMonthDay))
        }
        return parts.joined(separator: ", ")
    }

    private func addLeave() {
        guard canAddLeave else {
            alertMessage = addDisabledReason ?? Strings.insufficientLeave
            isSuccess = false
            showingAlert = true
            HapticFeedback.error()
            return
        }

        isSaving = true
        isNoteFocused = false

        let actualEndDate = length != .full ? startDate : endDate
        let today = Calendar.app.startOfDay(for: Date())
        let isPastLeave = startDate < today
        let status: LeaveStatus = isPastLeave ? .used : .planned

        let record = LeaveRecord(
            startDate: Calendar.app.startOfDay(for: startDate),
            endDate: Calendar.app.startOfDay(for: actualEndDate),
            type: category,
            status: status,
            note: note,
            length: length,
            bonusLeaveId: selectedBonusLeave?.id,  // 보너스 연결 — 삭제 시 usedDays 복원에 사용
            durationMinutes: length == .hours ? durationMinutes : nil,
            customTypeId: selectedBonusLeave == nil ? customType?.id : nil
        )
        modelContext.insert(record)

        // 보너스 연차 차감 (일반 연차는 레코드에서 자동 계산)
        if let bonus = selectedBonusLeave {
            bonus.usedDays += leaveDays
            if bonus.remainingDays <= 0 {
                bonus.isUsed = true
            }
        }

        do {
            try modelContext.save()
            // 대체휴무·공가·병가처럼 보너스와 같은 유형인데 보너스를 고르지 않았으면 여기서 바로 연결한다
            // (홈에 돌아가도 시트 위라 onAppear 재계산이 돌지 않는다)
            let records = allLeaveRecords.filter { $0.id != record.id } + [record]
            if BonusLeaveReconciler.reconcile(records: records, bonuses: unusedBonusLeaves) {
                try? modelContext.save()
            }
            let typeName = selectedBonusLeave != nil
                ? Strings.bonusLeaveTypeName(selectedBonusLeave!.type)
                : categoryName
            alertMessage = Strings.leaveRegistered(typeName)
            isSuccess = true
            // 초기화
            note = ""
            startDate = Date()
            endDate = Date()
            selectedBonusLeave = nil
            HapticFeedback.success()
            UsageReportingService.record(event: "leave_added:\(customType == nil ? category.rawValue : "custom")")
            if length == .hours { UsageReportingService.record(event: "leave_added_hours") }
            ReviewManager.shared.recordLeaveRegistration()
        } catch {
            alertMessage = Strings.saveFailed
            isSuccess = false
            HapticFeedback.error()
            // 롤백
            if let bonus = selectedBonusLeave {
                bonus.usedDays -= leaveDays
                if bonus.isUsed { bonus.isUsed = false }
            }
            modelContext.delete(record)
        }

        isSaving = false
        showingAlert = true
    }
}

// MARK: - 휴가 유형 선택기
struct LeaveTypePicker: View {
    @Binding var selectedType: LeaveType

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(LeaveType.allCases) { type in
                LeaveTypeButton(
                    type: type,
                    isSelected: selectedType == type
                ) {
                    selectedType = type
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct LeaveTypeButton: View {
    let type: LeaveType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticFeedback.selection()
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(Strings.leaveTypeName(type))
                    .font(.body)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? type.themeColor : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? type.themeColor : Color(.systemGray4), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - 보너스 연차 관리 뷰
struct BonusLeaveView: View {
    let bonusLeaves: [BonusLeave]

    @Environment(\.modelContext) private var modelContext

    @State private var showingAddSheet = false
    @State private var showingPaywall = false
    @State private var editingBonus: BonusLeave?
    @State private var bonusDays: Double = 1.0
    @State private var bonusType: BonusLeaveType = .compensatory
    @State private var bonusReason = ""
    @State private var hasExpiration = false
    @State private var expirationDate = Calendar.app.date(byAdding: .month, value: 3, to: Date())!
    @State private var pendingDeleteOffsets: IndexSet?
    @State private var showingDeleteConfirm = false
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false

    /// 보너스 연차는 프로 트림부터
    private var isPro: Bool { ProManager.shared.hasProTier }

    var activeBonusLeaves: [BonusLeave] {
        bonusLeaves.filter { !$0.isUsed }
    }

    var usedBonusLeaves: [BonusLeave] {
        bonusLeaves.filter { $0.isUsed }
    }

    var body: some View {
        Form {
            // 보너스 연차 추가 (Pro 전용)
            Section {
                Button {
                    if isPro {
                        showingAddSheet = true
                    } else {
                        showingPaywall = true
                    }
                } label: {
                    HStack {
                        Image(systemName: isPro ? "plus.circle.fill" : "lock.fill")
                            .foregroundStyle(isPro ? .green : .secondary)
                        Text(Strings.addBonusLeave)
                            .foregroundStyle(.primary)
                        Spacer()
                        if !isPro {
                            Text("Pro")
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.yellow.opacity(0.85))
                                .clipShape(Capsule())
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.body)
                        }
                    }
                }
            } footer: {
                Text(isPro ? Strings.bonusLeaveFooter : Strings.bonusLeaveFooterFree)
            }

            // 사용 가능한 보너스 연차
            if !activeBonusLeaves.isEmpty {
                Section(Strings.available) {
                    ForEach(activeBonusLeaves) { bonus in
                        BonusLeaveRow(bonus: bonus, editable: true)
                            .contentShape(Rectangle())
                            .onTapGesture { editingBonus = bonus }
                            .accessibilityElement(children: .combine)
                            .accessibilityAddTraits(.isButton)
                            .accessibilityHint(Text(Strings.editLeaveHint))
                    }
                    .onDelete(perform: deleteActiveBonus)
                }
            }

            // 사용 완료된 보너스 연차
            if !usedBonusLeaves.isEmpty {
                Section(Strings.usedComplete) {
                    ForEach(usedBonusLeaves) { bonus in
                        BonusLeaveRow(bonus: bonus, editable: false)
                    }
                }
            }

            // 비어있을 때
            if bonusLeaves.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "gift")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text(Strings.noBonusLeave)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddBonusLeaveSheet(
                bonusDays: $bonusDays,
                bonusType: $bonusType,
                bonusReason: $bonusReason,
                hasExpiration: $hasExpiration,
                expirationDate: $expirationDate,
                onSave: saveBonusLeave
            )
        }
        .sheet(item: $editingBonus) { bonus in
            EditBonusLeaveSheet(bonus: bonus)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(initialProductID: ProManager.yearlyProductID)
        }
        .alert(Strings.deleteBonusLeaveTitle, isPresented: $showingDeleteConfirm) {
            Button(Strings.cancel, role: .cancel) { pendingDeleteOffsets = nil }
            Button(Strings.delete, role: .destructive) { performDeleteActiveBonus() }
        } message: {
            Text(Strings.deleteBonusLeaveConfirm)
        }
        .alert(Strings.alert, isPresented: $showingErrorAlert) {
            Button(Strings.confirm, role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func deleteActiveBonus(at offsets: IndexSet) {
        pendingDeleteOffsets = offsets
        showingDeleteConfirm = true
    }

    private func performDeleteActiveBonus() {
        guard let offsets = pendingDeleteOffsets else { return }
        pendingDeleteOffsets = nil
        for index in offsets {
            modelContext.delete(activeBonusLeaves[index])
        }
        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            HapticFeedback.error()
            errorMessage = Strings.deleteFailed
            showingErrorAlert = true
        }
    }

    private func saveBonusLeave() {
        guard bonusDays > 0 else {
            HapticFeedback.error()
            return
        }

        let bonus = BonusLeave(
            days: bonusDays,
            type: bonusType,
            reason: bonusReason,
            expirationDate: hasExpiration ? expirationDate : nil
        )
        modelContext.insert(bonus)

        do {
            try modelContext.save()
            HapticFeedback.success()
            bonusDays = 1.0
            bonusType = .compensatory
            bonusReason = ""
            hasExpiration = false
            showingAddSheet = false
        } catch {
            modelContext.delete(bonus)
            HapticFeedback.error()
            errorMessage = Strings.saveFailed
            showingErrorAlert = true
        }
    }
}

// MARK: - 보너스 연차 추가 시트
struct AddBonusLeaveSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var bonusDays: Double
    @Binding var bonusType: BonusLeaveType
    @Binding var bonusReason: String
    @Binding var hasExpiration: Bool
    @Binding var expirationDate: Date

    let onSave: () -> Void

    /// 시간으로 넣기 — 보상휴가는 몇 시간씩 쌓이는 경우가 많다 (피드백: "add comp time by hour")
    @AppStorage(BonusLeave.inputInHoursKey) private var inHours = false
    @State private var bonusMinutes = 60

    var body: some View {
        NavigationStack {
            Form {
                Section(Strings.leaveDaysSection) {
                    Picker(Strings.allowanceUnitLabel, selection: $inHours) {
                        Text(Strings.allowanceUnitDays).tag(false)
                        Text(Strings.leaveHoursLabel).tag(true)
                    }
                    .pickerStyle(.segmented)

                    if inHours {
                        BonusHoursInput(minutes: $bonusMinutes)
                    } else {
                    HStack {
                        Text(Strings.daysToAdd)
                        Spacer()
                        TextField(Strings.dayUnitSuffix, value: $bonusDays, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text(Strings.dayUnitSuffix)
                    }

                    // 빠른 선택
                    HStack(spacing: 8) {
                        ForEach([0.25, 0.5, 1.0, 2.0, 3.0], id: \.self) { days in
                            Button {
                                bonusDays = days
                            } label: {
                                Text(days < 1 ? String(format: "%.2g", days) : "\(Int(days))")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(bonusDays == days ? Color.blue : Color(.systemGray5))
                                    .foregroundStyle(bonusDays == days ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(Text("\(Strings.dayCount(days))"))
                            .accessibilityAddTraits(bonusDays == days ? .isSelected : [])
                        }
                    }
                    }
                }
                .onChange(of: bonusMinutes) { _, m in if inHours { bonusDays = LeaveLength.days(forMinutes: m) } }
                .onChange(of: inHours) { _, hours in
                    if hours { bonusDays = LeaveLength.days(forMinutes: bonusMinutes) }
                    else { bonusDays = 1.0 }
                }
                .onAppear { if inHours { bonusDays = LeaveLength.days(forMinutes: bonusMinutes) } }

                Section(Strings.typeSection) {
                    Picker(Strings.typeSection, selection: $bonusType) {
                        ForEach(BonusLeaveType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(Strings.bonusLeaveTypeName(type))
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(Strings.reasonSection) {
                    TextField(Strings.reasonPlaceholder, text: $bonusReason)
                }

                Section {
                    Toggle(Strings.setExpiration, isOn: $hasExpiration)

                    if hasExpiration {
                        DatePicker(Strings.expirationDate, selection: $expirationDate, in: Date()..., displayedComponents: .date)
                    }
                } footer: {
                    Text(Strings.expirationFooter)
                }
            }
            .navigationTitle(Strings.addBonusLeave)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.save) {
                        // 시간으로 더했으면 시간 단위로도 쓸 수 있게 "시간 단위" 버튼을 켠다
                        if inHours { LeaveLength.usesHourlyLeave = true }
                        onSave()
                    }
                        .disabled(bonusDays <= 0)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 보너스 연차 수정 시트
struct EditBonusLeaveSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var bonus: BonusLeave

    @State private var editedDays: Double
    @State private var editedType: BonusLeaveType
    @State private var editedReason: String
    @State private var editedHasExpiration: Bool
    @State private var editedExpirationDate: Date
    @State private var showingSaveError = false
    @AppStorage(BonusLeave.inputInHoursKey) private var inHours = false
    @State private var editedMinutes: Int

    init(bonus: BonusLeave) {
        self.bonus = bonus
        _editedDays = State(initialValue: bonus.days)
        _editedMinutes = State(initialValue: BonusLeave.minutes(forDays: bonus.days))
        _editedType = State(initialValue: bonus.type)
        _editedReason = State(initialValue: bonus.reason)
        _editedHasExpiration = State(initialValue: bonus.expirationDate != nil)
        _editedExpirationDate = State(initialValue: bonus.expirationDate ?? Calendar.app.date(byAdding: .month, value: 3, to: Date())!)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(Strings.leaveDaysSection) {
                    Picker(Strings.allowanceUnitLabel, selection: $inHours) {
                        Text(Strings.allowanceUnitDays).tag(false)
                        Text(Strings.leaveHoursLabel).tag(true)
                    }
                    .pickerStyle(.segmented)

                    if inHours {
                        BonusHoursInput(minutes: $editedMinutes,
                                        minimumMinutes: BonusLeave.minutes(forDays: bonus.usedDays))
                    } else {
                    HStack {
                        Text(Strings.daysToAdd)
                        Spacer()
                        Text("\(String(format: editedDays == Double(Int(editedDays)) ? "%.0f" : "%.2g", editedDays))\(Strings.dayUnitSuffix)")
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                        Stepper(value: $editedDays, in: max(bonus.usedDays, 0.25)...365, step: 0.25) {
                            Text(Strings.daysToAdd)
                        }
                        .labelsHidden()
                        .accessibilityLabel(Text(Strings.daysToAdd))
                        .accessibilityValue(Text("\(Strings.dayCount(editedDays))"))
                    }
                    HStack(spacing: 8) {
                        ForEach([0.25, 0.5, 1.0, 2.0, 3.0], id: \.self) { d in
                            Button {
                                editedDays = d
                            } label: {
                                Text(d < 1 ? String(format: "%.2g", d) : "\(Int(d))")
                                    .font(.body).fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(editedDays == d ? Color.blue : Color(.systemGray5))
                                    .foregroundStyle(editedDays == d ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            .disabled(d < bonus.usedDays)
                            .accessibilityLabel(Text("\(Strings.dayCount(d))"))
                            .accessibilityAddTraits(editedDays == d ? .isSelected : [])
                        }
                    }

                    }

                    if bonus.usedDays > 0 {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                                .font(.body)
                            Text(Strings.bonusEditUsedRemaining(
                                used: inHours ? Strings.durationText(minutes: BonusLeave.minutes(forDays: bonus.usedDays))
                                              : String(format: "%.2g", bonus.usedDays),
                                remaining: inHours ? Strings.durationText(minutes: BonusLeave.minutes(forDays: max(0, editedDays - bonus.usedDays)))
                                                   : String(format: "%.2g", max(0, editedDays - bonus.usedDays))
                            ))
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section(Strings.typeSection) {
                    Picker(Strings.typeSection, selection: $editedType) {
                        ForEach(BonusLeaveType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(Strings.bonusLeaveTypeName(type))
                            }.tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(Strings.reasonSection) {
                    TextField(Strings.reasonPlaceholder, text: $editedReason)
                }

                Section {
                    Toggle(Strings.setExpiration, isOn: $editedHasExpiration)
                    if editedHasExpiration {
                        DatePicker(Strings.expirationDate, selection: $editedExpirationDate, in: Date()..., displayedComponents: .date)
                    }
                } footer: {
                    Text(Strings.expirationFooter)
                }
            }
            .onChange(of: editedMinutes) { _, m in if inHours { editedDays = LeaveLength.days(forMinutes: m) } }
            .onChange(of: inHours) { _, hours in
                // 단위만 바꿀 때는 양을 그대로 두고 표시만 바꾼다
                if hours { editedMinutes = BonusLeave.minutes(forDays: editedDays) }
            }
            .navigationTitle(Strings.bonusEditTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.save) { saveEdit() }
                        .disabled(editedDays <= 0 || editedDays < bonus.usedDays)
                }
            }
        }
        .presentationDetents([.medium])
        .alert(Strings.alert, isPresented: $showingSaveError) {
            Button(Strings.confirm, role: .cancel) { }
        } message: {
            Text(Strings.saveFailed)
        }
    }

    private func saveEdit() {
        bonus.days = editedDays
        bonus.type = editedType
        bonus.reason = editedReason
        bonus.expirationDate = editedHasExpiration ? editedExpirationDate : nil
        if bonus.remainingDays > 0 { bonus.isUsed = false }
        do {
            try modelContext.save()
            HapticFeedback.success()
            dismiss()
        } catch {
            HapticFeedback.error()
            showingSaveError = true
        }
    }
}

// MARK: - 보너스 연차 — 시간으로 넣기
/// 시간(직접 입력, 하루를 넘어도 됨) + 분(5분 단위), 그리고 며칠로 더해지는지
struct BonusHoursInput: View {
    @Binding var minutes: Int
    var minimumMinutes: Int = 0

    var body: some View {
        HStack {
            Text(Strings.leaveHoursLabel)
            Spacer()
            TextField("0", value: Binding(get: { minutes / 60 },
                                          set: { minutes = max(minimumMinutes, max(0, min(9999, $0)) * 60 + minutes % 60) }),
                      format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
                .frame(maxWidth: 100)
        }
        Stepper(value: Binding(get: { minutes % 60 },
                               set: { minutes = max(minimumMinutes, (minutes / 60) * 60 + $0) }),
                in: 0...55, step: 5) {
            HStack {
                Text(Strings.leaveMinutesLabel)
                Spacer()
                Text("\(minutes % 60)").monospacedDigit().foregroundStyle(.secondary)
            }
        }
        HStack(spacing: 8) {
            ForEach([1, 2, 4, 8], id: \.self) { h in
                Button {
                    minutes = max(minimumMinutes, h * 60)
                } label: {
                    Text(Strings.durationText(minutes: h * 60))
                        .font(.body).fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(minutes == h * 60 ? Color.blue : Color(.systemGray5))
                        .foregroundStyle(minutes == h * 60 ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(minutes == h * 60 ? .isSelected : [])
            }
        }
        Text(Strings.bonusHoursFooter(workday: Strings.durationText(minutes: LeaveLength.workdayMinutes),
                                      days: Strings.dayCount(LeaveLength.days(forMinutes: minutes))))
            .font(.body)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - 보너스 연차 행
struct BonusLeaveRow: View {
    let bonus: BonusLeave
    var editable: Bool = false
    @AppStorage(BonusLeave.inputInHoursKey) private var inHours = false

    var body: some View {
        HStack {
            Image(systemName: bonus.type.icon)
                .foregroundStyle(AppTheme.Colors.bonus)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(Strings.bonusLeaveTypeName(bonus.type))
                        .font(.body)
                        .fontWeight(.medium)
                    Text(inHours
                         ? "\(Strings.durationText(minutes: BonusLeave.minutes(forDays: bonus.remainingDays)))/\(Strings.durationText(minutes: BonusLeave.minutes(forDays: bonus.days)))"
                         : "\(String(format: "%.1f", bonus.remainingDays))/\(String(format: "%.1f", bonus.days))\(Strings.dayUnitSuffix)")
                        .font(.body)
                        .foregroundStyle(AppTheme.Colors.bonus)
                }

                if !bonus.reason.isEmpty {
                    Text(bonus.reason)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text(bonus.grantedDate, format: .dateTime.month().day())
                        .font(.body)
                        .foregroundStyle(.secondary)

                    if let expiration = bonus.expirationDate {
                        Text("~")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Text(expiration, format: .dateTime.month().day())
                            .font(.body)
                            .foregroundStyle(expiration < Date() ? .red : .secondary)
                    }
                }
            }

            Spacer()

            if bonus.isUsed {
                Text(Strings.usedComplete)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            } else if editable {
                Image(systemName: "pencil.circle")
                    .foregroundStyle(.secondary)
                    .font(.body)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 연차 기록 행
struct LeaveRecordRow: View {
    let record: LeaveRecord

    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"

        if record.type == .half || record.type == .quarter || Calendar.app.isDate(record.startDate, inSameDayAs: record.endDate) {
            return formatter.string(from: record.startDate)
        }
        return "\(formatter.string(from: record.startDate)) - \(formatter.string(from: record.endDate))"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: record.type.icon)
                            .font(.body)
                        Text(record.displayTypeName)
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(record.type.themeColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())

                    Text(Strings.leaveStatusName(record.status))
                        .font(.body)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(record.status.themeColor)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Text(dateRangeText)
                    .font(.body.bold())

                if !record.note.isEmpty {
                    Text(record.note)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if record.isRecommended {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppTheme.Colors.compensatory)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.displayTypeName), \(dateRangeText), \(Strings.leaveStatusName(record.status))")
    }
}

#Preview {
    @Previewable @State var profile = UserProfile(name: "Test", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 5)

    AddLeaveView(profile: profile)
}

// MARK: - 빠른 휴가 넣기
//
// 시트 양식 대신 달력 하나로 — 시작일과 끝나는 날을 누르면 "연차 2일 → 5일 쉼"이 바로 보이고,
// 하루만 더 쓰면 연휴가 이어질 때만 한 번 제안한다. 반차 · 종류 · 메모는 원래 양식(`AddLeaveView`)으로 넘긴다.
// 레퍼런스: Airbnb 날짜 고르기(두 번 눌러 기간), Google Flights 날짜 색(효율), 항공권 앱의 "하루 일찍" 넛지.

struct QuickAddLeaveSheet: View {
    @Bindable var profile: UserProfile
    let initialDate: Date

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allLeaveRecords: [LeaveRecord]
    @Query(filter: #Predicate<BonusLeave> { $0.isUsed == false })
    private var unusedBonusLeaves: [BonusLeave]
    @AppStorage("firstWeekday") private var firstWeekdayRaw = 0

    @State private var month = Date()
    @State private var start = Date()
    @State private var end = Date()
    @State private var didSetUp = false
    @State private var saved: Saved?
    @State private var shownRemaining: Double = 0
    @State private var showingFullForm = false
    @State private var recordCountBeforeFullForm = 0
    @State private var showingSaveError = false

    private let calendar = Calendar.app
    private var dayOff: DayOffCalendar { .shared }
    private var isLeisure: Bool { profile.userType == .leisure }

    struct Saved: Equatable {
        let start: Date
        let rest: Int
        let leave: Double
        let remainingAfter: Double
    }

    struct Block { let start: Date; let end: Date; var days: Int }

    // MARK: 계산

    private func day(_ d: Date, _ n: Int) -> Date {
        calendar.date(byAdding: .day, value: n, to: d) ?? d
    }

    /// 이미 넣어 둔 종일 휴가 날 — 연휴를 이을 때 쉬는 날로 본다
    private var existingLeaveDays: Set<Date> {
        var set = Set<Date>()
        for r in allLeaveRecords where r.status != .cancelled && r.length == .full {
            var d = calendar.startOfDay(for: r.startDate)
            let last = calendar.startOfDay(for: r.endDate)
            var guardCount = 0
            while d <= last && guardCount < 400 {
                set.insert(d); d = day(d, 1); guardCount += 1
            }
        }
        return set
    }

    private func isOff(_ d: Date, leave: Set<Date>) -> Bool {
        dayOff.isDayOff(d) || leave.contains(calendar.startOfDay(for: d))
    }

    /// 고른 기간 앞뒤로 쉬는 날을 이어 붙인 덩어리
    private func block(from s: Date, to e: Date, leave: Set<Date>) -> Block {
        var a = calendar.startOfDay(for: s)
        var b = calendar.startOfDay(for: e)
        var n = 0
        while isOff(day(a, -1), leave: leave) && n < 60 { a = day(a, -1); n += 1 }
        n = 0
        while isOff(day(b, 1), leave: leave) && n < 60 { b = day(b, 1); n += 1 }
        let days = (calendar.dateComponents([.day], from: a, to: b).day ?? 0) + 1
        return Block(start: a, end: b, days: days)
    }

    private var leaveDays: Double { Double(dayOff.workdays(from: start, to: end)) }

    private var available: Double {
        LeaveUsageCalculator.availableAnnual(on: start, records: Array(allLeaveRecords),
                                             annualGrant: profile.totalAnnualLeave, startMonth: profile.yearStart)
    }

    private var canSave: Bool {
        leaveDays > 0 && (isLeisure || leaveDays <= available)
    }

    /// 하루만 더 쓰면 주말 · 공휴일이 이어져 연휴가 3일 이상 길어질 때만
    private func magnet(leave: Set<Date>) -> (start: Date, end: Date, day: Date, block: Block)? {
        let current = block(from: start, to: end, leave: leave)
        if !isLeisure && leaveDays + 1 > available { return nil }
        var best: (start: Date, end: Date, day: Date, block: Block)?
        for candidate in [day(current.start, -1), day(current.end, 1)] {
            let s = min(start, candidate), e = max(end, candidate)
            let b = block(from: s, to: e, leave: leave)
            if b.days - current.days >= 3, b.days > (best?.block.days ?? 0) {
                best = (s, e, candidate, b)
            }
        }
        return best
    }

    private var blockedWarning: String? {
        guard dayOff.hasLeaveRestrictions else { return nil }
        var d = calendar.startOfDay(for: start)
        let last = calendar.startOfDay(for: end)
        var near = false
        while d <= last {
            if !dayOff.isDayOff(d) {
                if let name = dayOff.blackoutPeriodName(on: d) { return Strings.blackoutPeriodWarning(name) }
                if dayOff.isLeaveBlocked(d) { near = true }
            }
            d = day(d, 1)
        }
        return near ? Strings.blackoutWarning : nil
    }

    // MARK: 화면

    var body: some View {
        NavigationStack {
            ScrollView {
                if let saved {
                    savedView(saved)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    pickView
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(Strings.registerLeave)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.close) { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if saved == nil { saveBar }
            }
        }
        .onAppear {
            guard !didSetUp else { return }
            didSetUp = true
            let d = calendar.startOfDay(for: initialDate)
            start = d; end = d
            month = calendar.date(from: calendar.dateComponents([.year, .month], from: d)) ?? d
        }
        .sheet(isPresented: $showingFullForm, onDismiss: {
            // 원래 양식에서 넣었으면 이 화면도 닫는다 — 그냥 닫았으면 고르던 그대로 둔다
            if allLeaveRecords.count > recordCountBeforeFullForm { dismiss() }
        }) {
            AddLeaveView(profile: profile, initialDate: start, initialEndDate: end)
        }
        .alert(Strings.alert, isPresented: $showingSaveError) {
            Button(Strings.confirm, role: .cancel) { }
        } message: {
            Text(Strings.saveFailed)
        }
    }

    private var pickView: some View {
        let leave = existingLeaveDays
        let current = block(from: start, to: end, leave: leave)
        let mag = magnet(leave: leave)
        let single = calendar.isDate(start, inSameDayAs: end)
        return VStack(alignment: .leading, spacing: 16) {
            // 요약 — 고르는 대로 바로 바뀐다
            VStack(alignment: .leading, spacing: 4) {
                Text(leaveDays > 0 ? Strings.quickAddSummary(leave: leaveDays, rest: current.days)
                                   : Strings.quickAddNoLeaveNeeded)
                    .font(.title2.bold())
                    .contentTransition(.numericText())
                    .fixedSize(horizontal: false, vertical: true)
                Text(verbatim: "\(current.start.appMonthDay) – \(current.end.appMonthDay)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .animation(.snappy, value: current.days)

            QuickAddMonthGrid(
                month: $month,
                start: start, end: end,
                restBlock: (current.start, current.end),
                ghost: mag.map { ($0.block.start, $0.block.end) },
                showsHeat: single,
                firstWeekday: HolidayService.firstWeekday(for: dayOff.country, override: firstWeekdayRaw),
                isOff: { isOff($0, leave: leave) },
                heatDays: { block(from: $0, to: $0, leave: leave).days },
                onTap: pick
            )
            .padding()
            .cardSurface()

            if single {
                Text(Strings.quickAddHint)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // 하루만 더 쓰면 연휴가 이어질 때 — 한 번에 하나만
            if let mag {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Strings.quickAddMagnet(rest: mag.block.days))
                            .font(.body.bold())
                        Text(verbatim: mag.day.appFormatted(date: .full))
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Button(Strings.quickAddAttach) {
                        withAnimation(.snappy) { start = mag.start; end = mag.end }
                        HapticFeedback.success()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.Colors.gold)
                }
                .padding()
                .background(AppTheme.Colors.gold.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(AppTheme.Colors.gold, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])))
                .accessibilityElement(children: .combine)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // 문제가 있을 때만 한 줄
            if leaveDays > 0, !isLeisure, leaveDays > available {
                Label(Strings.insufficientLeave, systemImage: "exclamationmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(.orange)
            } else if let warning = blockedWarning {
                Label(warning, systemImage: "exclamationmark.triangle.fill")
                    .font(.body)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            } else if start < calendar.startOfDay(for: Date()) {
                Label(Strings.pastLeaveAutoUsed, systemImage: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .animation(.snappy, value: mag?.day)
    }

    private var saveBar: some View {
        HStack(spacing: 12) {
            Button {
                recordCountBeforeFullForm = allLeaveRecords.count
                showingFullForm = true
            } label: {
                Text(Strings.quickAddMoreOptions)
                    .font(.body)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.bordered)

            Button(action: save) {
                Text(Strings.save)
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canSave)
        }
        .controlSize(.large)
        .padding()
        .background(.bar)
    }

    private func savedView(_ s: Saved) -> some View {
        let today = calendar.startOfDay(for: Date())
        let dday = calendar.dateComponents([.day], from: today, to: s.start).day ?? 0
        return VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.Colors.gold)
                .symbolEffect(.bounce, value: saved)
                .voDecorative()
            if dday >= 0 {
                Text(verbatim: dday == 0 ? "D-Day" : "D-\(dday)")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .foregroundStyle(AppTheme.Colors.gold)
            }
            Text(Strings.quickAddRestDays(s.rest))
                .font(.title2.bold())
            Text(verbatim: s.start.appFormatted(date: .full))
                .font(.body)
                .foregroundStyle(.secondary)
            if !isLeisure {
                Text(Strings.quickAddRemaining(shownRemaining))
                    .font(.title3.bold())
                    .monospacedDigit()
                    .contentTransition(.numericText(value: shownRemaining))
                    .foregroundStyle(AppTheme.Colors.brand)
            }
            Button {
                dismiss()
            } label: {
                Text(Strings.confirm).font(.body.bold()).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .cardSurface()
        .padding()
        .accessibilityElement(children: .combine)
    }

    // MARK: 동작

    /// 하루만 골라 둔 상태에서 뒤의 날을 누르면 기간, 그 밖에는 그 날 하루로 새로 고른다
    private func pick(_ d: Date) {
        let d = calendar.startOfDay(for: d)
        withAnimation(.snappy) {
            if calendar.isDate(start, inSameDayAs: end), d > start {
                end = d
            } else {
                start = d; end = d
            }
        }
        HapticFeedback.selection()
    }

    private func save() {
        guard canSave else { return }
        let leave = existingLeaveDays
        let rest = block(from: start, to: end, leave: leave).days
        let before = available
        let used = leaveDays
        let today = calendar.startOfDay(for: Date())
        let record = LeaveRecord(
            startDate: calendar.startOfDay(for: start),
            endDate: calendar.startOfDay(for: end),
            type: .annual,
            status: start < today ? .used : .planned,
            length: .full
        )
        modelContext.insert(record)
        do {
            try modelContext.save()
            let records = allLeaveRecords.filter { $0.id != record.id } + [record]
            if BonusLeaveReconciler.reconcile(records: records, bonuses: unusedBonusLeaves) {
                try? modelContext.save()
            }
        } catch {
            modelContext.delete(record)
            HapticFeedback.error()
            showingSaveError = true
            return
        }
        HapticFeedback.success()
        UsageReportingService.record(event: "leave_added:\(LeaveType.annual.rawValue)")
        UsageReportingService.record(event: "leave_added_quick")
        ReviewManager.shared.recordLeaveRegistration()

        // 남은 연차가 굴러가며 줄어든다
        shownRemaining = before
        withAnimation(.snappy) {
            saved = Saved(start: block(from: start, to: end, leave: leave).start, rest: rest,
                          leave: used, remainingAfter: before - used)
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            withAnimation(.smooth(duration: 0.6)) { shownRemaining = before - used }
        }
    }
}

/// 빠른 넣기 달력 — 고른 기간, 이어지는 쉬는 날, 자석 제안 칸, 하루 고른 동안의 효율 색
private struct QuickAddMonthGrid: View {
    @Binding var month: Date
    let start: Date
    let end: Date
    let restBlock: (Date, Date)
    let ghost: (Date, Date)?
    let showsHeat: Bool
    let firstWeekday: Int
    let isOff: (Date) -> Bool
    let heatDays: (Date) -> Int
    let onTap: (Date) -> Void

    private let calendar = Calendar.app
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    private var days: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return [] }
        let blanks = (calendar.component(.weekday, from: first) - firstWeekday + 7) % 7
        var result: [Date?] = Array(repeating: nil, count: blanks)
        for n in range { result.append(calendar.date(byAdding: .day, value: n - 1, to: first)) }
        while result.count % 7 != 0 { result.append(nil) }
        return result
    }

    private var weekdays: [Int] { (0..<7).map { (firstWeekday - 1 + $0) % 7 + 1 } }

    private func within(_ d: Date, _ r: (Date, Date)) -> Bool {
        let s = calendar.startOfDay(for: d)
        return s >= calendar.startOfDay(for: r.0) && s <= calendar.startOfDay(for: r.1)
    }

    private func shiftMonth(_ n: Int) {
        withAnimation(.snappy) {
            month = calendar.date(byAdding: .month, value: n, to: month) ?? month
        }
        HapticFeedback.selection()
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button { shiftMonth(-1) } label: {
                    Image(systemName: "chevron.left").font(.body.bold()).frame(width: 44, height: 44)
                }
                .accessibilityLabel(Text(Strings.previousMonth))
                Spacer()
                Text(verbatim: Strings.monthYearFormat(year: calendar.component(.year, from: month), month: calendar.component(.month, from: month)))
                    .font(.headline)
                Spacer()
                Button { shiftMonth(1) } label: {
                    Image(systemName: "chevron.right").font(.body.bold()).frame(width: 44, height: 44)
                }
                .accessibilityLabel(Text(Strings.nextMonth))
            }

            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { w in
                    Text(Strings.weekdays[w - 1])
                        .font(.body.bold())
                        .foregroundStyle(w == 1 ? AppTheme.Colors.holiday : w == 7 ? AppTheme.Colors.brand : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .accessibilityHidden(true)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 4) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        cell(date)
                    } else {
                        Color.clear.frame(height: 44).accessibilityHidden(true)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func cell(_ date: Date) -> some View {
        let off = isOff(date)
        let selected = within(date, (start, end))
        let isLeave = selected && !off
        let inRest = within(date, restBlock)
        let inGhost = ghost.map { within(date, $0) && !inRest } ?? false
        let heat = (showsHeat && !off && !selected) ? heatDays(date) : 0
        let weekday = calendar.component(.weekday, from: date)

        Button { onTap(date) } label: {
            ZStack {
                // 이어지는 쉬는 날 띠
                if inRest {
                    Rectangle().fill(AppTheme.Colors.brand.opacity(0.14))
                } else if heat >= 4 {
                    RoundedRectangle(cornerRadius: 10).fill(AppTheme.Colors.gold.opacity(0.45)).padding(2)
                } else if heat == 3 {
                    RoundedRectangle(cornerRadius: 10).fill(AppTheme.Colors.gold.opacity(0.2)).padding(2)
                }
                if isLeave {
                    Circle().fill(AppTheme.Colors.brand).padding(3)
                }
                if inGhost {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(AppTheme.Colors.gold, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                        .padding(2)
                }
                Text(verbatim: "\(calendar.component(.day, from: date))")
                    .font(.body.weight(isLeave ? .bold : .regular))
                    .monospacedDigit()
                    .underline(differentiateWithoutColor && off && weekday != 1 && weekday != 7)
                    .foregroundStyle(isLeave ? Color.white
                                     : off ? (weekday == 7 ? AppTheme.Colors.brand : AppTheme.Colors.holiday)
                                     : Color.primary)
                if calendar.isDateInToday(date) && !isLeave {
                    Circle().strokeBorder(Color.primary.opacity(0.35), lineWidth: 1).padding(5)
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: date.appFormatted(date: .full)))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// 골드위크의 금색 — 연휴 · 효율 색 · 자석 제안
private extension AppTheme.Colors {
    static var gold: Color {
        Color(light: Color(red: 0.85, green: 0.6, blue: 0.0),
              dark: Color(red: 1.0, green: 0.76, blue: 0.2))
    }
}
