//
//  HomeView.swift
//  Goldweek
//
//  홈 대시보드 화면
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Bindable var profile: UserProfile
    @Query(sort: \LeaveRecord.startDate) private var leaveRecords: [LeaveRecord]
    @Environment(\.modelContext) private var modelContext

    @Query private var customHolidays: [CustomHoliday]
    @AppStorage("hiddenHolidayDates") private var hiddenHolidayDatesRaw: String = ""
    @State private var showingHistory = false
    @State private var showingPastLeaveEntry = false
    @AppStorage("hasSeenPastLeavePrompt") private var hasSeenPastLeavePrompt = false
    @AppStorage("lastProBannerShownAt") private var lastProBannerShownAt: Double = 0

    private let holidayService = HolidayService()

    private var hiddenDates: Set<String> {
        Set(hiddenHolidayDatesRaw.split(separator: ",").map(String.init).filter { !$0.isEmpty })
    }

    var committedLeave: Double {
        let active = leaveRecords.filter { $0.status == .used || $0.status == .planned }
        let deducting = active.filter { $0.deductsFromAnnualLeave }
        return deducting.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }

    // MARK: - Pro 배너 트리거

    /// 7일 쿨다운 이후, 의미 있는 상황일 때만 배너 표시
    var proBannerContext: (icon: String, message: String)? {
        guard !ProManager.shared.isPro else { return nil }
        let cooldown: Double = 7 * 24 * 3600
        guard Date().timeIntervalSince1970 - lastProBannerShownAt >= cooldown else { return nil }

        let cal = Calendar.current
        let now = Date()
        let month = cal.component(.month, from: now)
        let year = cal.component(.year, from: now)
        let remaining = max(0, profile.totalAnnualLeave - committedLeave)
        let hasPlanned = leaveRecords.contains { $0.status == .planned }

        // 1. 14일 이내 공휴일 임박
        let holidays = holidayService.getHolidays(for: year, country: profile.country,
                                                    customHolidays: customHolidays,
                                                    hiddenDates: hiddenDates)
        if let nextHoliday = holidays.first(where: {
            let d = cal.dateComponents([.day], from: cal.startOfDay(for: now), to: $0.date).day ?? 999
            return d >= 1 && d <= 14
        }) {
            let d = cal.dateComponents([.day], from: cal.startOfDay(for: now), to: nextHoliday.date).day ?? 0
            return ("🎌", Strings.proBannerHolidayUpcoming(nextHoliday.name, days: d))
        }

        // 2. 연말 연차 소멸 위험 (11~12월, 잔여 > 2일)
        if month >= 11, remaining > 2 {
            return ("⏳", Strings.proBannerYearEndExpiry(formatLeave(remaining)))
        }

        // 3. 황금연휴 시즌 (4월 20일~5월, 9월 20일~10월) + 예정 없음
        let day = cal.component(.day, from: now)
        let isGoldenSeason = (month == 4 && day >= 20) || month == 5 || (month == 9 && day >= 20) || month == 10
        if isGoldenSeason, !hasPlanned, remaining >= 1 {
            let seasonName = month <= 5 ? Strings.goldenSeasonName : Strings.chuseokSeasonName
            return ("🌸", Strings.proBannerSeasonOpportunity(seasonName))
        }

        // 4. 잔여 연차 부족 (3일 미만, 상반기)
        if remaining < 3, month <= 6 {
            return ("⚠️", Strings.proBannerLowRemaining(formatLeave(remaining)))
        }

        // 5. 연차 많은데 예정 없음 (7일 초과, 3월 이후)
        if remaining > 7, !hasPlanned, month >= 3 {
            return ("📅", Strings.proBannerEmptyPlan(formatLeave(remaining)))
        }

        return nil
    }

    var upcomingLeaves: [LeaveRecord] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let today = calendar.startOfDay(for: Date())

        return leaveRecords.filter { record in
            let recordYear = calendar.component(.year, from: record.startDate)
            return recordYear == currentYear &&
                   record.startDate >= today &&
                   record.status == .planned
        }
        .sorted { $0.startDate < $1.startDate }
    }

    var usedLeavesCount: Int {
        leaveRecords.filter { $0.status == .used || $0.status == .planned }.count
    }

    /// 연차 기준월 이후 1개월 이상 경과했고 아직 아무 기록도 없는 경우 배너 표시 (직장인만)
    var shouldShowPastLeavePrompt: Bool {
        guard !hasSeenPastLeavePrompt, leaveRecords.isEmpty else { return false }
        guard profile.userType == .employee else { return false }
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let startMonth = profile.yearStartMonth
        let monthsElapsed = (month - startMonth + 12) % 12
        return monthsElapsed >= 1
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 연차 현황 카드
                    LeaveStatusCard(profile: profile)

                    // 휴가 페이스 (소진 속도 + 번아웃 신호) — 직장인 모드 + 데이터 충분 시
                    if profile.userType == .employee, profile.totalAnnualLeave > 0, !leaveRecords.isEmpty {
                        BurnoutPaceCard(profile: profile, allLeaveRecords: leaveRecords)
                    }

                    // 이전 연차 빠른 입력 배너 (기록 없고 기준월 1개월+ 경과)
                    if shouldShowPastLeavePrompt {
                        PastLeavePromptBanner(
                            onQuickEntry: { showingPastLeaveEntry = true },
                            onDismiss: { hasSeenPastLeavePrompt = true }
                        )
                    }

                    // Pro 업그레이드 배너 (스마트 트리거: 쿨다운 + 의미 있는 상황일 때만)
                    if let context = proBannerContext {
                        ProBannerView(
                            triggerIcon: context.icon,
                            triggerMessage: context.message,
                            onShow: { lastProBannerShownAt = Date().timeIntervalSince1970 }
                        )
                    }

                    // 다가오는 휴가
                    if !upcomingLeaves.isEmpty {
                        UpcomingLeavesSection(leaves: upcomingLeaves)
                    }

                    // 휴가 사용 내역 버튼 (맨 아래)
                    LeaveHistoryButton(
                        usedCount: usedLeavesCount,
                        action: { showingHistory = true }
                    )

                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingHistory) {
                LeaveHistoryView(yearStartMonth: profile.yearStartMonth)
            }
            .sheet(isPresented: $showingPastLeaveEntry) {
                PastLeaveQuickEntrySheet(profile: profile)
                    .onDisappear { hasSeenPastLeavePrompt = true }
            }
        }
    }

}

// MARK: - 연차 현황 카드
struct LeaveStatusCard: View {
    @Bindable var profile: UserProfile
    @Query(filter: #Predicate<BonusLeave> { $0.isUsed == false })
    private var activeBonusLeaves: [BonusLeave]
    @Query private var allBonusLeaves: [BonusLeave]
    @Query private var allLeaveRecords: [LeaveRecord]
    @AppStorage("includeBonusInStatus") private var includeBonusInStatus: Bool = true
    @State private var showingAddLeave = false

    /// 연차 기준 연도의 시작일 (yearStartMonth 기준)
    var annualYearStart: Date {
        let cal = Calendar.current
        let now = Date()
        let year = cal.component(.year, from: now)
        let month = cal.component(.month, from: now)
        let sm = profile.yearStartMonth
        let startYear = month >= sm ? year : year - 1
        return cal.date(from: DateComponents(year: startYear, month: sm, day: 1)) ?? now
    }

    /// 연차 기준 연도의 종료일
    var annualYearEnd: Date {
        let cal = Calendar.current
        return cal.date(byAdding: DateComponents(year: 1, second: -1), to: annualYearStart) ?? annualYearStart
    }

    /// 현재 연차 연도에 해당하는 레코드만 필터
    var currentYearRecords: [LeaveRecord] {
        allLeaveRecords.filter { $0.startDate >= annualYearStart && $0.startDate <= annualYearEnd }
    }

    /// 잔여 보너스 (미만료 + 미사용, remainingDays 기준)
    var remainingBonusLeave: Double {
        let now = Date()
        return activeBonusLeaves
            .filter { $0.expirationDate == nil || $0.expirationDate! > now }
            .reduce(0) { $0 + $1.remainingDays }
    }

    /// 최초 부여된 보너스 전체
    var grantedBonusLeave: Double {
        allBonusLeaves.reduce(0) { $0 + $1.days }
    }

    /// 사용된 보너스 (usedDays 합산)
    var usedBonusLeave: Double {
        allBonusLeaves.reduce(0) { $0 + $1.usedDays }
    }

    /// 사용완료 연차 — 현재 연차 연도 기준
    /// status == .used 이거나, .planned이지만 endDate가 이미 지난 경우 포함
    var actualUsed: Double {
        let today = Calendar.current.startOfDay(for: Date())
        let records = currentYearRecords.filter { record in
            guard record.deductsFromAnnualLeave else { return false }
            return record.status == .used ||
                   (record.status == .planned && Calendar.current.startOfDay(for: record.endDate) < today)
        }
        return records.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }

    /// 예정 연차 — 현재 연차 연도 기준 (endDate가 오늘 이후인 .planned만)
    var plannedLeave: Double {
        let today = Calendar.current.startOfDay(for: Date())
        let records = currentYearRecords.filter { record in
            guard record.deductsFromAnnualLeave else { return false }
            return record.status == .planned && Calendar.current.startOfDay(for: record.endDate) >= today
        }
        return records.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }

    /// 확정 연차 총합 (used + planned) — 잔여 계산용
    var committedLeave: Double { actualUsed + plannedLeave }

    /// "총" — 보너스 포함 시 부여량 기준
    var totalLeave: Double {
        includeBonusInStatus ? profile.totalAnnualLeave + grantedBonusLeave : profile.totalAnnualLeave
    }

    /// "완료" 표시값 — 보너스 포함 ON 시 사용된 보너스도 합산 (보존 법칙 유지)
    var displayUsed: Double {
        includeBonusInStatus ? actualUsed + usedBonusLeave : actualUsed
    }

    /// "남은" — 남은 annual + 잔여 보너스
    var effectiveRemaining: Double {
        let annualRemaining = max(0, profile.totalAnnualLeave - committedLeave)
        return includeBonusInStatus ? annualRemaining + remainingBonusLeave : annualRemaining
    }

    var remainingPercentage: Double {
        guard totalLeave > 0 else { return 0 }
        return effectiveRemaining / totalLeave
    }

    private var isLeisure: Bool { profile.userType == .leisure }
    private var hasGoal: Bool { profile.totalAnnualLeave > 0 }

    var body: some View {
        VStack(spacing: 16) {
            // 헤더 — 보너스 포함 여부는 설정 화면에서 제어한다.
            HStack {
                Text(isLeisure ? Strings.leisureVacationPlanTitle : Strings.annualLeaveStatusTitle)
                    .font(.headline)
                Spacer()
                Button {
                    showingAddLeave = true
                } label: {
                    Image(systemName: "plus")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 32, height: 32)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel(Text(Strings.registerLeave))
            }

            // 프로그레스 바 — 완료(파랑) / 예정(시안) / 남은(초록) 3분할
            if !isLeisure || hasGoal {
                GeometryReader { geometry in
                    let total = max(totalLeave, 0.001)
                    let usedFrac   = min(max(displayUsed  / total, 0), 1)
                    let plannedFrac = min(max(plannedLeave / total, 0), 1 - usedFrac)
                    let remFrac    = max(1 - usedFrac - plannedFrac, 0)
                    let w = geometry.size.width

                    ZStack(alignment: .leading) {
                        // 트랙
                        Capsule().fill(Color.gray.opacity(0.15))

                        // 세그먼트 (Capsule clip으로 양 끝 둥글게)
                        HStack(spacing: 2) {
                            if usedFrac > 0 {
                                Color.blue
                                    .frame(width: max(w * usedFrac - 1, 0))
                            }
                            if plannedFrac > 0 {
                                Color.cyan.opacity(0.85)
                                    .frame(width: max(w * plannedFrac - 1, 0))
                            }
                            if remFrac > 0 {
                                let remColors: [Color] = isLeisure
                                    ? [.purple, .pink]
                                    : (includeBonusInStatus && remainingBonusLeave > 0 ? [AppTheme.Colors.bonus, Color.yellow] : [.green, .mint])
                                LinearGradient(colors: remColors, startPoint: .leading, endPoint: .trailing)
                                    .frame(width: max(w * remFrac, 0))
                            }
                        }
                        .clipShape(Capsule())
                    }
                }
                .frame(height: 20)
            }

            // 통계 3열
            HStack {
                VStack(alignment: .leading) {
                    Text(Strings.statUsed)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(formatLeave(displayUsed))\(Strings.dayUnitSuffix)")
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                }

                Spacer()

                VStack {
                    Text(Strings.statPlanned)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(formatLeave(plannedLeave))\(Strings.dayUnitSuffix)")
                        .font(.title2.bold())
                        .foregroundStyle(.cyan)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(isLeisure ? (hasGoal ? Strings.statRemainingGoal : Strings.statPlanned) : Strings.remaining)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if isLeisure && !hasGoal {
                        // 무제한 모드: 총 계획/완료일 표시
                        Text("\(formatLeave(actualUsed + plannedLeave))\(Strings.dayUnitSuffix)")
                            .font(.title2.bold())
                            .foregroundStyle(.purple)
                    } else {
                        Text("\(formatLeave(effectiveRemaining))\(Strings.dayUnitSuffix)")
                            .font(.title2.bold())
                            .foregroundStyle(
                                isLeisure ? .purple
                                : includeBonusInStatus && remainingBonusLeave > 0 ? AppTheme.Colors.bonus : .green
                            )
                    }
                }
            }
            .voCard(VoiceOverLabel.leaveBalance(total: totalLeave, used: displayUsed, remaining: effectiveRemaining))

            // 보너스 연차 별도 표시 — 직장인 모드 + 미포함 상태에서만
            if !isLeisure, remainingBonusLeave > 0, !includeBonusInStatus {
                Divider()
                HStack(spacing: 6) {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(AppTheme.Colors.bonus)
                        .font(.subheadline)
                        .voDecorative()
                    Text(Strings.bonus)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("+\(formatLeave(remainingBonusLeave))\(Strings.dayUnitSuffix)")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.Colors.bonus)
                    Text(Strings.usable)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.Colors.bonus.opacity(0.12))
                        .clipShape(Capsule())
                }
                .voCard(VoiceOverLabel.bonus(days: remainingBonusLeave))
            }

            // 자유 계획 무제한 안내
            if isLeisure && !hasGoal {
                Divider()
                HStack(spacing: 6) {
                    Image(systemName: "infinity")
                        .foregroundStyle(.purple)
                        .font(.subheadline)
                        .voDecorative()
                    Text(Strings.goalNotSetDesc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .sheet(isPresented: $showingAddLeave) {
            AddLeaveView(profile: profile)
        }
    }

}

// MARK: - 다가오는 휴가 섹션
struct UpcomingLeavesSection: View {
    let leaves: [LeaveRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(Strings.upcomingLeaves)
                    .font(.headline)
                    .voHeader()
                Spacer()
            }

            ForEach(leaves) { leave in
                UpcomingLeaveRow(leave: leave)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct UpcomingLeaveRow: View {
    let leave: LeaveRecord

    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: leave.startDate).day ?? 0
    }

    /// 노트가 비어있을 때 표시할 제목 — 연차 계열은 "휴가", 그 외(출장·병가·공가 등)는 타입명 그대로 노출
    private var defaultTitle: String {
        switch leave.type {
        case .annual, .half, .quarter: return Strings.vacation
        default: return Strings.leaveTypeName(leave.type)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(leave.note.isEmpty ? defaultTitle : leave.note)
                    .font(.subheadline.bold())

                Text("\(leave.startDate.formatted(date: .abbreviated, time: .omitted)) - \(leave.endDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("D-\(daysUntil)")
                    .font(.headline)
                    .foregroundStyle(.blue)

                Text("\(Strings.leaveTypeName(leave.type)) \(formatLeave(leave.effectiveLeaveDays))\(Strings.dayUnitSuffix)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .voCard(
            VoiceOverLabel.upcomingLeave(
                dateRange: "\(leave.startDate.formatted(date: .abbreviated, time: .omitted)) - \(leave.endDate.formatted(date: .abbreviated, time: .omitted))",
                typeLabel: Strings.leaveTypeName(leave.type),
                days: leave.effectiveLeaveDays,
                dDay: daysUntil
            )
        )
    }
}

// MARK: - 휴가 사용 내역 버튼
struct LeaveHistoryButton: View {
    let usedCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Strings.leaveHistory)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(Strings.checkPastRecords)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .voDecorative()
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("\(Strings.leaveHistory), \(Strings.checkPastRecords)"))
        .accessibilityValue(usedCount > 0 ? Text(Strings.itemCount(usedCount)) : Text(""))
    }
}

// MARK: - 이전 연차 입력 배너
struct PastLeavePromptBanner: View {
    let onQuickEntry: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .foregroundStyle(.orange)
                        .voDecorative()
                    Text(Strings.pastLeavePromptTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .voHeader()
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(Text(Strings.cancel))
            }

            Text(Strings.pastLeavePromptDesc)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onQuickEntry) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .voDecorative()
                    Text(Strings.pastLeaveQuickAdd)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.orange)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - 이전 연차 빠른 입력 시트
struct PastLeaveQuickEntrySheet: View {
    @Bindable var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var daysUsed: Double = 1.0
    @State private var isSaving = false

    private let calendar = Calendar.current

    private var yearStartDate: Date {
        let year = calendar.component(.year, from: Date())
        var components = DateComponents()
        components.year = year
        components.month = profile.yearStartMonth
        components.day = 1
        return calendar.date(from: components) ?? Date()
    }

    private var yesterday: Date {
        calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date())) ?? Date()
    }

    private var maxDays: Double {
        Double(min(Int(profile.totalAnnualLeave), 30))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(Strings.pastLeaveSheetDesc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }

                Section(Strings.pastLeaveTotalUsed) {
                    HStack {
                        Text("\(String(format: daysUsed == Double(Int(daysUsed)) ? "%.0f" : "%.1f", daysUsed))\(Strings.dayUnitSuffix)")
                            .font(.title2.bold())
                            .foregroundStyle(.orange)
                        Spacer()
                        Stepper("", value: $daysUsed, in: 0.5...maxDays, step: 0.5)
                            .labelsHidden()
                    }

                    HStack(spacing: 8) {
                        ForEach([1.0, 2.0, 3.0, 5.0, 7.0, 10.0], id: \.self) { days in
                            Button {
                                daysUsed = days
                            } label: {
                                Text("\(Int(days))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 7)
                                    .background(daysUsed == days ? Color.orange : Color(.systemGray5))
                                    .foregroundStyle(daysUsed == days ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text("\(yearStartDate.formatted(.dateTime.month().day()))  →  \(yesterday.formatted(.dateTime.month().day()))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text(Strings.pastLeaveSheetFooter)
                }
            }
            .navigationTitle(Strings.pastLeaveSheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveEntry) {
                        if isSaving {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Text(Strings.pastLeaveConfirm).fontWeight(.semibold)
                        }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func saveEntry() {
        guard daysUsed > 0 else { return }
        isSaving = true

        // effectiveLeaveDays = daysUsed가 되도록 endDate를 계산
        let calendar = Calendar.current
        let adjustedEnd = calendar.date(byAdding: .day, value: max(0, Int(daysUsed) - 1), to: yearStartDate) ?? yearStartDate
        let record = LeaveRecord(
            startDate: yearStartDate,
            endDate: adjustedEnd,
            type: .annual,
            status: .used,
            note: Strings.pastLeaveSummaryNote
        )
        modelContext.insert(record)

        do {
            try modelContext.save()
            HapticFeedback.success()
            dismiss()
        } catch {
            modelContext.delete(record)
            HapticFeedback.error()
        }
        isSaving = false
    }
}

// MARK: - 휴가 페이스 카드 (소진 속도 + 번아웃 신호)
struct BurnoutPaceCard: View {
    @Bindable var profile: UserProfile
    let allLeaveRecords: [LeaveRecord]

    /// 번아웃 평가 — 렌더당 1회만 계산 (예측 루프 중복 방지)
    private let assessment: BurnoutAssessment

    init(profile: UserProfile, allLeaveRecords: [LeaveRecord]) {
        self._profile = Bindable(wrappedValue: profile)
        self.allLeaveRecords = allLeaveRecords
        self.assessment = BurnoutEngine().assess(
            breaks: BurnoutEngine.restBlocks(from: allLeaveRecords),
            asOf: Date()
        )
    }

    private let cal = Calendar.current

    // MARK: 회계연도 범위
    private var annualYearStart: Date {
        let now = Date()
        let year = cal.component(.year, from: now)
        let month = cal.component(.month, from: now)
        let sm = profile.yearStartMonth
        let startYear = month >= sm ? year : year - 1
        return cal.date(from: DateComponents(year: startYear, month: sm, day: 1)) ?? now
    }
    private var annualYearEnd: Date {
        cal.date(byAdding: DateComponents(year: 1, second: -1), to: annualYearStart) ?? annualYearStart
    }

    // MARK: 사용/예정 일수
    private var actualUsed: Double {
        let today = cal.startOfDay(for: Date())
        return allLeaveRecords.filter { record in
            guard record.deductsFromAnnualLeave else { return false }
            guard record.startDate >= annualYearStart && record.startDate <= annualYearEnd else { return false }
            return record.status == .used ||
                   (record.status == .planned && cal.startOfDay(for: record.endDate) < today)
        }.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }
    private var plannedLeave: Double {
        let today = cal.startOfDay(for: Date())
        return allLeaveRecords.filter { record in
            guard record.deductsFromAnnualLeave else { return false }
            guard record.startDate >= annualYearStart && record.startDate <= annualYearEnd else { return false }
            return record.status == .planned && cal.startOfDay(for: record.endDate) >= today
        }.reduce(0.0) { $0 + $1.effectiveLeaveDays }
    }

    // MARK: 진행률 (0.0 ~ 1.0)
    private var yearProgress: Double {
        let now = Date()
        let total = annualYearEnd.timeIntervalSince(annualYearStart)
        guard total > 0 else { return 0 }
        let elapsed = now.timeIntervalSince(annualYearStart)
        return max(0, min(1, elapsed / total))
    }
    private var usageProgress: Double {
        guard profile.totalAnnualLeave > 0 else { return 0 }
        return min(1, (actualUsed + plannedLeave) / profile.totalAnnualLeave)
    }

    // MARK: 페이스 (1.0 = 적정)
    private var pace: Double {
        guard yearProgress > 0.05 else { return 1.0 }
        return usageProgress / yearProgress
    }

    private enum PaceCategory { case slow, healthy, fast, veryFast }
    private var paceCategory: PaceCategory {
        if pace < 0.7 { return .slow }
        if pace <= 1.3 { return .healthy }
        if pace <= 1.7 { return .fast }
        return .veryFast
    }
    private var paceLabel: String {
        switch paceCategory {
        case .slow: return Strings.paceLabelSlow
        case .healthy: return Strings.paceLabelHealthy
        case .fast: return Strings.paceLabelFast
        case .veryFast: return Strings.paceLabelVeryFast
        }
    }
    private var paceColor: Color {
        switch paceCategory {
        case .slow: return AppTheme.Colors.brand
        case .healthy: return AppTheme.Colors.success
        case .fast: return AppTheme.Colors.compensatory
        case .veryFast: return AppTheme.Colors.error
        }
    }

    // MARK: 휴가 텀 (번아웃 지표)
    /// 쉬어가는 흐름에서 "사무실에서 벗어난 시간"으로 카운트할 레코드.
    /// 일이긴 하지만 일상 루틴에서 벗어나는 출장도 리프레시 효과가 있어 포함.
    private func countsAsBreak(_ record: LeaveRecord) -> Bool {
        record.deductsFromAnnualLeave || record.type == .businessTrip
    }

    private var lastLeaveDate: Date? {
        let today = cal.startOfDay(for: Date())
        return allLeaveRecords.compactMap { record -> Date? in
            guard countsAsBreak(record) else { return nil }
            let endDay = cal.startOfDay(for: record.endDate)
            guard endDay <= today else { return nil }
            guard record.status == .used || record.status == .planned else { return nil }
            return record.endDate
        }.max()
    }
    private var nextPlannedLeave: Date? {
        let today = cal.startOfDay(for: Date())
        return allLeaveRecords.compactMap { record -> Date? in
            guard countsAsBreak(record) else { return nil }
            let startDay = cal.startOfDay(for: record.startDate)
            guard startDay > today, record.status == .planned else { return nil }
            return record.startDate
        }.min()
    }
    private var daysSinceLastLeave: Int? {
        guard let last = lastLeaveDate else { return nil }
        return cal.dateComponents([.day], from: cal.startOfDay(for: last), to: cal.startOfDay(for: Date())).day
    }
    private var daysUntilNextLeave: Int? {
        guard let next = nextPlannedLeave else { return nil }
        return cal.dateComponents([.day], from: cal.startOfDay(for: Date()), to: cal.startOfDay(for: next)).day
    }

    private enum BurnoutRisk { case healthy, warning, risky, plannedAhead }
    /// 엔진 레벨 → 기존 표시 enum 매핑 (타임라인/메시지 호환 유지)
    private var burnoutRisk: BurnoutRisk {
        if assessment.primaryReason == .planAhead { return .plannedAhead }
        switch assessment.level {
        case .ok:       return .healthy
        case .mindful:  return .warning
        case .overdue:  return .warning
        case .critical: return .risky
        }
    }
    private var burnoutColor: Color {
        switch burnoutRisk {
        case .healthy, .plannedAhead: return AppTheme.Colors.success
        case .warning: return AppTheme.Colors.compensatory
        case .risky: return AppTheme.Colors.error
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack(spacing: 8) {
                Text(Strings.paceCardTitle)
                    .font(.headline)
                Spacer()
            }

            // Section 1: 진행률 vs 사용률 비교
            paceSection

            Divider()

            // Section 2: 번아웃 신호 (휴가 텀 타임라인)
            burnoutSection
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    // MARK: - 페이스 섹션 (하나의 축 + 두 개의 핀)
    private var paceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 범례 — 라벨/값은 트랙에서 분리해 좌·우로 배치(겹침 방지)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                paceLegend(label: Strings.paceYearProgressLabel,
                           value: "\(Int(yearProgress * 100))%",
                           color: Color(.systemGray),
                           usesNowMarker: true)
                Spacer(minLength: 12)
                paceLegend(label: Strings.paceUsageLabel,
                           value: "\(Int(usageProgress * 100))%",
                           color: paceColor)
            }

            // 단일 연간 축 + 두 핀 (텍스트 없이 마커만)
            GeometryReader { geo in
                let w = max(geo.size.width, 1)
                let trackY: CGFloat = 11
                let yearX = min(max(w * CGFloat(yearProgress), 0), w)
                let usageX = min(max(w * CGFloat(usageProgress), 0), w)
                let ahead = usageProgress >= yearProgress  // 사용이 진행보다 앞서면 빠른 페이스

                ZStack(alignment: .topLeading) {
                    // 연간 축 트랙
                    Capsule()
                        .fill(Color(.systemGray6))
                        .frame(width: w, height: 8)
                        .position(x: w / 2, y: trackY)

                    // 두 핀 사이 구간 강조 (페이스 갭)
                    Capsule()
                        .fill(paceColor.opacity(ahead ? 0.35 : 0.18))
                        .frame(width: abs(usageX - yearX), height: 8)
                        .position(x: (usageX + yearX) / 2, y: trackY)

                    // 올해 진행: '지금'을 가리키는 세로선 마커 (시간의 흐름 — 의지와 무관)
                    nowMarker.position(x: yearX, y: trackY)
                    // 연차 사용: 내 행동을 나타내는 핀 헤드
                    pinHead(color: paceColor).position(x: usageX, y: trackY)
                }
            }
            .frame(height: 22)
        }
    }

    private func paceLegend(label: String, value: String, color: Color, usesNowMarker: Bool = false) -> some View {
        HStack(spacing: 6) {
            if usesNowMarker {
                Capsule()
                    .fill(color)
                    .frame(width: 3, height: 12)
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 9, height: 9)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .monospacedDigit()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    /// '지금'을 가리키는 세로선 — 트랙을 가로지르는 재생 헤드 느낌
    private var nowMarker: some View {
        Capsule()
            .fill(Color(.systemGray))
            .frame(width: 3, height: 20)
            .overlay(Capsule().stroke(Color(.systemBackground), lineWidth: 1.5))
    }

    private func pinHead(color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 13, height: 13)
            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
    }

    // MARK: - 번아웃 섹션
    private var burnoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(Strings.burnoutSectionTitle)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if assessment.cycleIsPersonalized {
                    Text(Strings.personalCycleLabel(assessment.personalCycleDays))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            recoveryReserveRow
            forecastRow

            timelineRow
        }
    }

    /// 회복 잔량 게이지 — 과거 휴식이 준 회복을 fade-out으로 적분한 현재 잔량
    private var recoveryReserveRow: some View {
        let ratio = assessment.recoveryReserveRatio
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(Strings.recoveryReserveLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(ratio * 100))%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(burnoutColor)
                    .monospacedDigit()
            }
            GeometryReader { geo in
                let w = max(geo.size.width, 1)
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray6)).frame(height: 8)
                    Capsule().fill(burnoutColor)
                        .frame(width: w * CGFloat(ratio), height: 8)
                }
            }
            .frame(height: 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Strings.recoveryReserveLabel)
        .accessibilityValue("\(Int(ratio * 100))%")
    }

    /// 번아웃 예측 라인 — 현 속도면 위험 진입 예상 시점 (또는 안정/지금)
    private var forecastRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "waveform.path.ecg")
                .font(.caption)
                .foregroundStyle(burnoutColor)
            Text(forecastText)
                .font(.caption)
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
        }
    }

    private var forecastText: String {
        if assessment.level == .critical { return Strings.burnoutForecastNow }
        guard let date = assessment.predictedRiskDate else { return Strings.burnoutForecastClear }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: Strings.localeIdentifier)
        fmt.setLocalizedDateFormatFromTemplate("yMMM")
        return Strings.burnoutForecast(fmt.string(from: date))
    }

    /// 오늘의 가로 위치 비율 (0 = 지난 휴가 쪽 끝, 1 = 다음 휴가 쪽 끝)
    /// 실제 일수 비율을 그대로 쓰면 한쪽이 찌그러지므로 0.5 기준으로 완화하고
    /// [0.25, 0.75] 범위로 클램프해 "어느 쪽이 더 가까운지"만 직관적으로 드러낸다.
    private var todayFraction: CGFloat {
        guard let since = daysSinceLastLeave, let until = daysUntilNextLeave else { return 0.5 }
        let s = Double(max(since, 0))
        let u = Double(max(until, 0))
        let total = s + u
        guard total > 0 else { return 0.5 }
        let raw = s / total                  // since가 클수록(지난 휴가가 멀수록) 오늘은 오른쪽
        let soft = 0.5 + (raw - 0.5) * 0.6   // 비율 완화
        return CGFloat(min(max(soft, 0.25), 0.75))
    }

    private var todayNode: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(burnoutColor)
                    .frame(width: 14, height: 14)
                Circle()
                    .stroke(burnoutColor.opacity(0.3), lineWidth: 4)
                    .frame(width: 22, height: 22)
            }
            Text(Strings.burnoutToday)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }

    private var timelineRow: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let nodeW: CGFloat = 56
            let cellW: CGFloat = 72
            let budget = max(w - nodeW - cellW * 2, 0)
            let frac = todayFraction
            let leftW = budget * frac          // 지난 휴가 ~ 오늘 사이
            let rightW = budget * (1 - frac)   // 오늘 ~ 다음 휴가 사이

            HStack(spacing: 0) {
                // 지난 휴가
                timelineCell(
                    title: Strings.burnoutLast,
                    value: daysSinceLastLeave.map { Strings.burnoutDaysAgo($0) } ?? Strings.burnoutNoLast,
                    hasData: daysSinceLastLeave != nil,
                    color: lastLeaveColor
                )
                .frame(width: cellW)

                // 연결선 (왼쪽) — 멀수록 길어진다
                connector(filled: daysSinceLastLeave != nil, color: lastLeaveColor)
                    .frame(width: leftW)

                // 오늘 (비율에 따라 좌우로 이동)
                todayNode
                    .frame(width: nodeW)

                // 연결선 (오른쪽) — 가까울수록 짧아진다
                connector(filled: nextPlannedLeave != nil, color: AppTheme.Colors.brand)
                    .frame(width: rightW)

                // 다음 휴가
                timelineCell(
                    title: Strings.burnoutNext,
                    value: daysUntilNextLeave.map { Strings.burnoutDaysAhead($0) } ?? Strings.burnoutNoNext,
                    hasData: daysUntilNextLeave != nil,
                    color: AppTheme.Colors.brand
                )
                .frame(width: cellW)
            }
            .frame(width: w)
        }
        .frame(height: 52)
    }

    private var lastLeaveColor: Color {
        guard let since = daysSinceLastLeave else { return .secondary }
        if since < 60 { return AppTheme.Colors.success }
        if since < 90 { return AppTheme.Colors.compensatory }
        return AppTheme.Colors.error
    }

    private func timelineCell(title: String, value: String, hasData: Bool, color: Color) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(hasData ? color : Color(.systemGray4))
                .frame(width: 10, height: 10)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(hasData ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func connector(filled: Bool, color: Color) -> some View {
        Rectangle()
            .fill(filled ? color.opacity(0.4) : Color(.systemGray5))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 28)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, LeaveRecord.self, configurations: config)

    let profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 5)
    container.mainContext.insert(profile)

    return HomeView(profile: profile)
        .modelContainer(container)
}
