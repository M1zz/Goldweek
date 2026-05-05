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

                    // 휴가 사용 내역 버튼
                    LeaveHistoryButton(
                        usedCount: usedLeavesCount,
                        action: { showingHistory = true }
                    )

                    // 다가오는 휴가
                    if !upcomingLeaves.isEmpty {
                        UpcomingLeavesSection(leaves: upcomingLeaves)
                    }

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
    private var year: Int { Calendar.current.component(.year, from: Date()) }

    var body: some View {
        VStack(spacing: 16) {
            // 헤더
            HStack {
                Text(isLeisure ? "\(year)년 휴가 계획" : Strings.annualLeaveStatus(year: year))
                    .font(.headline)
                Spacer()
                // 보너스 포함 토글 — 직장인 모드에서만
                if !isLeisure, remainingBonusLeave > 0 {
                    Button {
                        includeBonusInStatus.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: includeBonusInStatus ? "gift.fill" : "gift")
                                .font(.caption)
                            Text(Strings.includeBonus)
                                .font(.caption)
                        }
                        .foregroundStyle(includeBonusInStatus ? AppTheme.Colors.bonus : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(includeBonusInStatus ? AppTheme.Colors.bonus.opacity(0.12) : Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
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

            // 보너스 연차 별도 표시 — 직장인 모드 + 미포함 상태에서만
            if !isLeisure, remainingBonusLeave > 0, !includeBonusInStatus {
                Divider()
                HStack(spacing: 6) {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(AppTheme.Colors.bonus)
                        .font(.subheadline)
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
            }

            // 자유 계획 무제한 안내
            if isLeisure && !hasGoal {
                Divider()
                HStack(spacing: 6) {
                    Image(systemName: "infinity")
                        .foregroundStyle(.purple)
                        .font(.subheadline)
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
    }

}

// MARK: - 다가오는 휴가 섹션
struct UpcomingLeavesSection: View {
    let leaves: [LeaveRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📅 \(Strings.upcomingLeaves)")
                    .font(.headline)
                Spacer()
                Text(Strings.itemCount(leaves.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(leaves) { leave in
                UpcomingLeaveRow(leave: leave)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct UpcomingLeaveRow: View {
    let leave: LeaveRecord

    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: leave.startDate).day ?? 0
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(leave.note.isEmpty ? Strings.vacation : leave.note)
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
    }
}

// MARK: - 휴가 사용 내역 버튼
struct LeaveHistoryButton: View {
    let usedCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(Strings.leaveHistory)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Text(Strings.checkPastRecords)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if usedCount > 0 {
                    Text(Strings.itemCount(usedCount))
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
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
                    Text(Strings.pastLeavePromptTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(Strings.pastLeavePromptDesc)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onQuickEntry) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
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
    private var paceMessage: String {
        switch paceCategory {
        case .slow: return Strings.paceMessageSlow
        case .healthy: return Strings.paceMessageHealthy
        case .fast: return Strings.paceMessageFast
        case .veryFast: return Strings.paceMessageVeryFast
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
    private var lastLeaveDate: Date? {
        let today = cal.startOfDay(for: Date())
        return allLeaveRecords.compactMap { record -> Date? in
            guard record.deductsFromAnnualLeave else { return nil }
            let endDay = cal.startOfDay(for: record.endDate)
            guard endDay <= today else { return nil }
            guard record.status == .used || record.status == .planned else { return nil }
            return record.endDate
        }.max()
    }
    private var nextPlannedLeave: Date? {
        let today = cal.startOfDay(for: Date())
        return allLeaveRecords.compactMap { record -> Date? in
            guard record.deductsFromAnnualLeave else { return nil }
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
    private var burnoutRisk: BurnoutRisk {
        // 30일 내 다음 계획이 있으면 안전감 우선
        if let until = daysUntilNextLeave, until <= 30 { return .plannedAhead }
        guard let since = daysSinceLastLeave else {
            // 마지막 휴가 자체가 없는 경우 회계연도 진행률 기반
            if yearProgress < 0.25 { return .healthy }
            if yearProgress < 0.5 { return .warning }
            return .risky
        }
        if since < 60 { return .healthy }
        if since < 90 { return .warning }
        return .risky
    }
    private var burnoutColor: Color {
        switch burnoutRisk {
        case .healthy, .plannedAhead: return AppTheme.Colors.success
        case .warning: return AppTheme.Colors.compensatory
        case .risky: return AppTheme.Colors.error
        }
    }
    private var burnoutIcon: String {
        switch burnoutRisk {
        case .healthy: return "heart.fill"
        case .plannedAhead: return "sparkles"
        case .warning: return "moon.zzz.fill"
        case .risky: return "exclamationmark.bubble.fill"
        }
    }
    private var burnoutMessage: String {
        switch burnoutRisk {
        case .healthy: return Strings.burnoutMsgHealthy
        case .plannedAhead: return Strings.burnoutMsgPlannedAhead
        case .warning: return Strings.burnoutMsgWarning
        case .risky: return Strings.burnoutMsgRisky
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack(spacing: 8) {
                Image(systemName: "speedometer")
                    .foregroundStyle(paceColor)
                Text(Strings.paceCardTitle)
                    .font(.headline)
                Spacer()
                Text(paceLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(paceColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(paceColor.opacity(0.12))
                    .clipShape(Capsule())
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

    // MARK: - 페이스 섹션
    private var paceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 올해 진행
            comparisonBar(
                label: Strings.paceYearProgressLabel,
                value: yearProgress,
                color: Color(.systemGray2),
                trailing: "\(Int(yearProgress * 100))%"
            )
            // 연차 사용
            comparisonBar(
                label: Strings.paceUsageLabel,
                value: usageProgress,
                color: paceColor,
                trailing: "\(Int(usageProgress * 100))%"
            )

            Text(paceMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
    }

    private func comparisonBar(label: String, value: Double, color: Color, trailing: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(trailing)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color)
                    .monospacedDigit()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray6))
                    Capsule()
                        .fill(color)
                        .frame(width: max(0, geo.size.width * CGFloat(value)))
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - 번아웃 섹션
    private var burnoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: burnoutIcon)
                    .foregroundStyle(burnoutColor)
                    .font(.subheadline)
                Text(Strings.burnoutSectionTitle)
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }

            timelineRow

            Text(burnoutMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var timelineRow: some View {
        HStack(spacing: 0) {
            // 지난 휴가
            timelineCell(
                title: Strings.burnoutLast,
                value: daysSinceLastLeave.map { Strings.burnoutDaysAgo($0) } ?? Strings.burnoutNoLast,
                hasData: daysSinceLastLeave != nil,
                color: lastLeaveColor
            )

            // 연결선 (왼쪽)
            connector(filled: daysSinceLastLeave != nil, color: lastLeaveColor)

            // 오늘 (중앙)
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
            .frame(width: 56)

            // 연결선 (오른쪽)
            connector(filled: nextPlannedLeave != nil, color: AppTheme.Colors.brand)

            // 다음 휴가
            timelineCell(
                title: Strings.burnoutNext,
                value: daysUntilNextLeave.map { Strings.burnoutDaysAhead($0) } ?? Strings.burnoutNoNext,
                hasData: daysUntilNextLeave != nil,
                color: AppTheme.Colors.brand
            )
        }
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
