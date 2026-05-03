//
//  HomeView.swift
//  LeaveWise
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
            return ("🎌", "\(nextHoliday.name) D-\(d) · 연차 붙여 긴 휴가 만들어 보세요")
        }

        // 2. 연말 연차 소멸 위험 (11~12월, 잔여 > 2일)
        if month >= 11, remaining > 2 {
            return ("⏳", "연말까지 \(formatLeave(remaining))일 남았어요 · 소멸 전에 계획하세요")
        }

        // 3. 황금연휴 시즌 (4월 20일~5월, 9월 20일~10월) + 예정 없음
        let day = cal.component(.day, from: now)
        let isGoldenSeason = (month == 4 && day >= 20) || month == 5 || (month == 9 && day >= 20) || month == 10
        if isGoldenSeason, !hasPlanned, remaining >= 1 {
            let seasonName = month <= 5 ? "황금연휴" : "추석 연휴"
            return ("🌸", "\(seasonName) 시즌 · AI 추천으로 최적의 일정 만들어 보세요")
        }

        // 4. 잔여 연차 부족 (3일 미만, 상반기)
        if remaining < 3, month <= 6 {
            return ("⚠️", "남은 연차 \(formatLeave(remaining))일 · 효율적으로 배치해 보세요")
        }

        // 5. 연차 많은데 예정 없음 (7일 초과, 3월 이후)
        if remaining > 7, !hasPlanned, month >= 3 {
            return ("📅", "\(formatLeave(remaining))일 연차가 비어 있어요 · AI 추천 받아보세요")
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
                            Text("보너스 포함")
                                .font(.caption)
                        }
                        .foregroundStyle(includeBonusInStatus ? .orange : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(includeBonusInStatus ? Color.orange.opacity(0.12) : Color.gray.opacity(0.1))
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
                                    : (includeBonusInStatus && remainingBonusLeave > 0 ? [.orange, .yellow] : [.green, .mint])
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
                    Text("완료")
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
                    Text(isLeisure ? (hasGoal ? "남은 목표" : "계획됨") : Strings.remaining)
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
                                : includeBonusInStatus && remainingBonusLeave > 0 ? .orange : .green
                            )
                    }
                }
            }

            // 보너스 연차 별도 표시 — 직장인 모드 + 미포함 상태에서만
            if !isLeisure, remainingBonusLeave > 0, !includeBonusInStatus {
                Divider()
                HStack(spacing: 6) {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(.orange)
                        .font(.subheadline)
                    Text(Strings.bonus)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("+\(formatLeave(remainingBonusLeave))\(Strings.dayUnitSuffix)")
                        .font(.title3.bold())
                        .foregroundStyle(.orange)
                    Text("사용 가능")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.12))
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
                    Text("목표 일수 없음 · 설정에서 연간 목표를 설정할 수 있어요")
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
                    Text("날짜별로 개별 입력하려면 + 탭을 이용하세요")
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, LeaveRecord.self, configurations: config)

    let profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 5)
    container.mainContext.insert(profile)

    return HomeView(profile: profile)
        .modelContainer(container)
}
