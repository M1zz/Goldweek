//
//  UsageStatsView.swift
//  Goldweek
//
//  개발자(마스터 모드) 전용 — 공용 허브(FeedbackHub)에서 실제 데이터를 읽어 보여준다.
//   ① 사용자 수·활성 사용자 (UsageSnapshot)
//   ② 기간별 추이 (UsageEvent)
//   ③ 효용 지표·활성화 퍼널·리텐션 — "이 앱이 값을 하는가"의 근거
//   ④ 접수된 피드백 요약 → 인박스로 이동
//
//  ⚠️ 남의 레코드를 읽는 화면이라 CloudKit 컨테이너 read 권한이 필요하다(피드백 인박스와 동일).
//     스키마·권한 절차: docs/USAGE_STATS_HUB.md
//  ⚠️ 사용자에게 보이지 않는 개발자 화면이라 문자열을 번역하지 않는다.
//     그래서 `Text(verbatim:)`을 쓴다 — 문자열 카탈로그에 미번역 항목으로 쌓이지 않게.
//

import SwiftUI
import Charts
import LeeoKit

struct UsageStatsView: View {
    @State private var snapshots: [UsageReportingService.Snapshot] = []
    @State private var eventSamples: [UsageReportingService.EventSample] = []
    @State private var feedback: [LeeoFeedbackService.FeedbackRecord] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    /// 이벤트 표본을 이름별로 묶은 것 — 차트와 같은 원본을 쓴다.
    private var events: [UsageReportingService.EventStat] {
        UsageReportingService.eventStats(from: eventSamples)
    }

    var body: some View {
        List {
            if isLoading && snapshots.isEmpty && eventSamples.isEmpty {
                Section {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text(verbatim: "불러오는 중…")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                // 일부만 실패해도(예: 아직 스키마 미배포) 읽어온 것은 그대로 보여준다.
                if let errorMessage {
                    Section {
                        Text(verbatim: errorMessage)
                            .foregroundStyle(.red)
                    } footer: {
                        Text(verbatim: "전체 통계를 읽으려면 CloudKit 컨테이너의 read 권한과 UsageSnapshot·UsageEvent 스키마 배포가 필요해요.")
                    }
                }
                usersSection
                trendSection
                valueSection
                activationSection
                paywallSection
                retentionSection
                eventsSection
                averagesSection
                sharesSection
                distributionSection
                feedbackSection
            }
        }
        .navigationTitle(Text(verbatim: "사용 통계"))
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .refreshable { await load() }
    }

    // MARK: - 사용자

    private var usersSection: some View {
        Section {
            statRow("사용 중인 사람 (설치)", "\(snapshots.count)")
            statRow("최근 7일 활성", "\(activeCount(days: 7))")
            statRow("최근 30일 활성", "\(activeCount(days: 30))")
            statRow("최근 7일 신규", "\(newCount(days: 7))")
            statRow("누적 실행", "\(snapshots.reduce(0) { $0 + $1.launchCount })")
        } header: {
            Text(verbatim: "사용자")
        } footer: {
            Text(verbatim: "설치마다 익명 스냅샷 1건이라, 설치 수 = 이 앱을 쓰는 기기 수예요. 재설치하면 새 설치로 잡혀요.")
        }
    }

    // MARK: - 기간별 추이

    private var trendSection: some View {
        Section {
            UsageTrendChart(events: eventSamples, snapshots: snapshots)
        } header: {
            Text(verbatim: "기간별 추이")
        } footer: {
            Text(verbatim: "일·주·월·연 단위로 묶어서 보여줘요. 차트를 좌우로 넘기면 과거로 이동하고, 막대를 탭하면 정확한 날짜와 숫자가 나와요.")
        }
    }

    // MARK: - 효용 지표

    @ViewBuilder
    private var valueSection: some View {
        let signals = UsageInsights.valueSignals(snapshots: snapshots)
        if !signals.isEmpty {
            Section {
                ForEach(signals) { signal in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(verbatim: signal.name)
                            Spacer()
                            Text(verbatim: signal.value)
                                .font(.body.monospacedDigit().weight(.semibold))
                        }
                        Text(verbatim: signal.hint)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 1)
                    .accessibilityElement(children: .combine)
                }
            } header: {
                Text(verbatim: "효용 지표")
            } footer: {
                Text(verbatim: "설치 수보다 이쪽이 먼저다. 사람이 늘어도 '휴가를 등록한 설치'가 안 늘면 앱이 값을 못 하고 있는 것.")
            }
        }
    }

    // MARK: - 활성화 퍼널

    @ViewBuilder
    private var activationSection: some View {
        let stages = UsageInsights.activationFunnel(snapshots: snapshots, events: eventSamples)
        if (stages.first?.installs ?? 0) > 0 {
            Section {
                ForEach(stages) { stage in funnelRow(stage) }
            } header: {
                Text(verbatim: "활성화 퍼널")
            } footer: {
                Text(verbatim: "설치 → 온보딩 → 첫 휴가 등록 → 추천 채택. 가장 크게 떨어지는 칸이 지금 고쳐야 할 곳이에요. (아래 단계는 이벤트 조회 범위 안의 설치만 잡혀요)")
            }
        }
    }

    @ViewBuilder
    private var paywallSection: some View {
        let stages = UsageInsights.paywallFunnel(events: eventSamples)
        if (stages.first?.installs ?? 0) > 0 {
            Section {
                ForEach(stages) { stage in funnelRow(stage) }
            } header: {
                Text(verbatim: "결제 전환 퍼널")
            } footer: {
                Text(verbatim: "같은 이벤트는 설치당 6시간에 한 번만 기록돼요. 절대 건수보다 단계 사이의 비율을 보세요.")
            }
        }
    }

    private func funnelRow(_ stage: UsageInsights.FunnelStage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(verbatim: stage.name)
                    .fontWeight(.medium)
                Spacer()
                Text(verbatim: "설치 \(stage.installs)곳")
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.18))
                    Capsule().fill(Color.accentColor)
                        .frame(width: max(2, geo.size.width * stage.rateFromTop))
                }
            }
            .frame(height: 6)
            Text(verbatim: "전체 대비 \(percent(stage.rateFromTop)) · 직전 단계 대비 \(percent(stage.rateFromPrevious))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    // MARK: - 리텐션

    @ViewBuilder
    private var retentionSection: some View {
        let rows = UsageInsights.weeklyRetention(snapshots: snapshots, events: eventSamples)
        if !rows.isEmpty {
            Section {
                ForEach(rows.prefix(8)) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(verbatim: cohortLabel(row.cohortStart))
                                .fontWeight(.medium)
                            Spacer()
                            Text(verbatim: "설치 \(row.size)곳")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 14) {
                            retentionCell("D1", row.rate(row.day1))
                            retentionCell("D7", row.rate(row.day7))
                            retentionCell("D30", row.rate(row.day30))
                        }
                    }
                    .padding(.vertical, 2)
                    .accessibilityElement(children: .combine)
                }
            } header: {
                Text(verbatim: "리텐션 (주간 코호트)")
            } footer: {
                Text(verbatim: "설치한 주별로 묶어 며칠 뒤에도 앱을 열었는지 봐요. 아직 그날이 오지 않은 설치는 세지 않으니 최근 코호트의 D30은 낮게 보입니다. 연차 앱은 매일 여는 앱이 아니라 D1이 낮은 게 정상이에요.")
            }
        }
    }

    private func retentionCell(_ label: String, _ rate: Double) -> some View {
        VStack(spacing: 2) {
            Text(verbatim: label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(verbatim: percent(rate))
                .font(.body.monospacedDigit().weight(.medium))
        }
    }

    // MARK: - 앱 사용 내용

    private var eventsSection: some View {
        Section {
            if events.isEmpty {
                Text(verbatim: "아직 기록된 사용 내용이 없어요.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(events) { event in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(verbatim: event.name)
                            .fontWeight(.medium)
                        Text(verbatim: "\(event.count)건 · 설치 \(event.installs)곳")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        } header: {
            Text(verbatim: "앱 사용 내용")
        } footer: {
            Text(verbatim: "최근 이벤트 3,000건 기준이에요. 같은 이벤트는 설치당 6시간에 한 번만 기록되니, 건수보다 '설치 몇 곳이 쓰는지'를 보세요.")
        }
    }

    // MARK: - 설치당 평균

    @ViewBuilder
    private var averagesSection: some View {
        let averages = metricAverages
        if !averages.isEmpty {
            Section {
                ForEach(averages, id: \.key) { item in
                    statRow(UsageInsights.metricLabel(item.key), format(item.value))
                }
            } header: {
                Text(verbatim: "설치당 평균")
            }
        }
    }

    // MARK: - 사용자 비율 (플래그·국가·유형)

    @ViewBuilder
    private var sharesSection: some View {
        let shares = flagShares
        if !shares.isEmpty {
            Section {
                ForEach(shares, id: \.key) { item in
                    statRow(UsageInsights.metricLabel(item.key),
                            "\(Int((item.rate * 100).rounded()))% (\(item.count))")
                }
            } header: {
                Text(verbatim: "사용자 비율")
            }
        }
    }

    // MARK: - 버전 / 플랫폼

    @ViewBuilder
    private var distributionSection: some View {
        if !snapshots.isEmpty {
            Section {
                ForEach(distribution(\.appVersion), id: \.key) { item in
                    statRow(item.key, "\(item.count)")
                }
            } header: {
                Text(verbatim: "버전 분포")
            }
            Section {
                ForEach(distribution(\.locale), id: \.key) { item in
                    statRow(item.key, "\(item.count)")
                }
            } header: {
                Text(verbatim: "언어·지역")
            }
        }
    }

    // MARK: - 피드백

    private var feedbackSection: some View {
        Section {
            statRow("접수된 피드백", "\(feedback.count)")
            statRow("아직 처리 안 함", "\(feedback.filter { !$0.isDone }.count)")
            NavigationLink(destination: LeeoFeedbackInboxView<GoldweekSpec>()) {
                Label {
                    Text(verbatim: "피드백 전부 보기")
                } icon: {
                    Image(systemName: "tray.full")
                }
            }
        } header: {
            Text(verbatim: "피드백")
        } footer: {
            Text(verbatim: "최근 100건 기준이에요. 완료 표시는 이 기기에만 저장됩니다.")
        }
    }

    // MARK: - Row

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(verbatim: label)
            Spacer()
            Text(verbatim: value)
                .font(.body.monospacedDigit().weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - 집계 (클라이언트 계산)

    private func activeCount(days: Int) -> Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return snapshots.filter { ($0.lastActiveAt ?? .distantPast) >= cutoff }.count
    }

    private func newCount(days: Int) -> Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return snapshots.filter { ($0.installDate ?? .distantPast) >= cutoff }.count
    }

    private struct Bucket: Identifiable { let key: String; let count: Int; var id: String { key } }
    private func distribution(_ keyPath: KeyPath<UsageReportingService.Snapshot, String>) -> [Bucket] {
        Dictionary(grouping: snapshots) { $0[keyPath: keyPath] }
            .map { Bucket(key: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    /// 0/1 플래그가 아닌 수치 지표 — 값을 가진 설치들의 평균.
    private struct MetricAvg { let key: String; let value: Double }
    private var metricAverages: [MetricAvg] {
        var sums: [String: (total: Double, n: Int)] = [:]
        for snapshot in snapshots {
            for (key, value) in snapshot.metrics where !UsageInsights.isFlag(key) {
                let current = sums[key] ?? (0, 0)
                sums[key] = (current.total + value, current.n + 1)
            }
        }
        return sums
            .map { MetricAvg(key: $0.key, value: $0.value.n > 0 ? $0.value.total / Double($0.value.n) : 0) }
            .sorted { $0.key < $1.key }
    }

    /// 0/1 플래그·국가·유형 — 전체 설치 대비 비율.
    private struct FlagShare { let key: String; let rate: Double; let count: Int }
    private var flagShares: [FlagShare] {
        guard !snapshots.isEmpty else { return [] }
        var counts: [String: Int] = [:]
        for snapshot in snapshots {
            for (key, value) in snapshot.metrics where UsageInsights.isFlag(key) && value >= 1 {
                counts[key, default: 0] += 1
            }
        }
        return counts
            .map { FlagShare(key: $0.key, rate: Double($0.value) / Double(snapshots.count), count: $0.value) }
            .sorted { $0.count > $1.count }
    }

    private func percent(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }

    private func format(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }

    private func cohortLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 주"
        return formatter.string(from: date)
    }

    // MARK: - Load

    private func load() async {
        isLoading = true
        errorMessage = nil
        var failures: [String] = []

        do { snapshots = try await UsageReportingService.fetchSnapshots() }
        catch { failures.append(error.localizedDescription) }

        do { eventSamples = try await UsageReportingService.fetchEvents() }
        catch { failures.append(error.localizedDescription) }

        do { feedback = try await UsageReportingService.fetchFeedback() }
        catch { failures.append(error.localizedDescription) }

        if !failures.isEmpty {
            errorMessage = "불러오지 못했어요: " + Set(failures).joined(separator: "\n")
        }
        isLoading = false
    }
}

// MARK: - 기간별 추이 차트

/// 일·주·월·연 단위로 묶어 보여주는 막대 차트. 좌우 스크롤 + 막대 탭 판독.
///
/// ⚠️ 막대는 눈으로 정확히 읽을 수 없다 — y축 눈금이 4개뿐이고 x축 라벨은 5개만 나온다.
///    그래서 탭한 자리의 날짜와 값을 글자로 못박아 준다.
struct UsageTrendChart: View {
    let events: [UsageReportingService.EventSample]
    let snapshots: [UsageReportingService.Snapshot]

    @State private var unit: UsageReportingService.BucketUnit = .day
    @State private var metric: TrendMetric = .activeInstalls
    @State private var scrollPosition = Date()
    @State private var selectedDate: Date?

    enum TrendMetric: String, CaseIterable, Identifiable {
        case activeInstalls, events, newInstalls
        var id: String { rawValue }

        var localizedName: String {
            switch self {
            case .activeInstalls: return "활동한 사용자"
            case .events: return "사용 건수"
            case .newInstalls: return "신규 사용자"
            }
        }

        func value(_ point: UsageReportingService.TrendPoint) -> Int {
            switch self {
            case .activeInstalls: return point.activeInstalls
            case .events: return point.events
            case .newInstalls: return point.newInstalls
            }
        }
    }

    private var points: [UsageReportingService.TrendPoint] {
        UsageReportingService.trend(unit: unit, events: events, snapshots: snapshots)
    }

    /// 스크롤 창 길이(초) — 보이는 묶음 개수만큼.
    private var visibleDomain: TimeInterval {
        let bucketSeconds: TimeInterval
        switch unit {
        case .day: bucketSeconds = 86_400
        case .week: bucketSeconds = 7 * 86_400
        case .month: bucketSeconds = 30.5 * 86_400
        case .year: bucketSeconds = 365.25 * 86_400
        }
        return bucketSeconds * Double(unit.visibleBuckets)
    }

    private var visiblePoints: [UsageReportingService.TrendPoint] {
        let end = scrollPosition.addingTimeInterval(visibleDomain)
        return points.filter { $0.date >= scrollPosition && $0.date < end }
    }

    /// 탭한 x 좌표에 해당하는 묶음 — `chartXSelection`이 주는 건 막대가 아니라 누른 자리의 시각이다.
    private var selectedPoint: UsageReportingService.TrendPoint? {
        guard let selectedDate else { return nil }
        return points.min {
            abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("", selection: $unit) {
                ForEach(UsageReportingService.BucketUnit.allCases) { unit in
                    Text(verbatim: unit.localizedName).tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel(Text(verbatim: "기간 단위"))

            Picker("", selection: $metric) {
                ForEach(TrendMetric.allCases) { metric in
                    Text(verbatim: metric.localizedName).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel(Text(verbatim: "표시할 값"))

            if points.isEmpty {
                Text(verbatim: "아직 그릴 데이터가 없어요.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                chart
                summary
            }
        }
        .padding(.vertical, 4)
        .onAppear { scrollToLatest() }
        // 단위가 바뀌면 고른 자리도 뜻이 달라진다(같은 날을 가리켜도 이제 '그 달'이다) — 지운다.
        .onChange(of: unit) { _, _ in
            selectedDate = nil
            scrollToLatest()
        }
        .onChange(of: points.count) { _, _ in scrollToLatest() }
    }

    private var chart: some View {
        Chart(points) { point in
            BarMark(
                x: .value("기간", point.date, unit: unit.calendarComponent),
                y: .value(metric.localizedName, metric.value(point))
            )
            .foregroundStyle(Color.accentColor.gradient)
            .opacity(selectedPoint == nil || selectedPoint?.id == point.id ? 1 : 0.35)
            .accessibilityLabel(Text(verbatim: Self.axisLabel(point.date, unit: unit)))
            .accessibilityValue(Text(verbatim: "\(metric.value(point))"))

            if let selected = selectedPoint, selected.id == point.id {
                RuleMark(x: .value("기간", selected.date, unit: unit.calendarComponent))
                    .foregroundStyle(Color.secondary.opacity(0.35))
                    .zIndex(-1)
                    .annotation(position: .top, spacing: 4,
                                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        readout(for: selected)
                    }
            }
        }
        .chartXSelection(value: $selectedDate)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(verbatim: Self.axisLabel(date, unit: unit))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4))
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: visibleDomain)
        .chartScrollPosition(x: $scrollPosition)
        .chartScrollTargetBehavior(.valueAligned(matching: scrollAlignment))
        .frame(height: 200)
    }

    private func readout(for point: UsageReportingService.TrendPoint) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(verbatim: Self.fullLabel(point.date, unit: unit))
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(verbatim: "\(metric.localizedName) \(metric.value(point))")
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.12), radius: 4, y: 1)
        )
        .accessibilityElement(children: .combine)
    }

    /// 스크롤이 묶음 경계에 딱 맞게 멈추도록 — 단위별 정렬 기준.
    private var scrollAlignment: DateComponents {
        switch unit {
        case .day: return DateComponents(hour: 0)
        case .week: return DateComponents(hour: 0, weekday: Calendar.current.firstWeekday)
        case .month: return DateComponents(day: 1)
        case .year: return DateComponents(month: 1, day: 1)
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: visibleRangeText)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(verbatim: "이 구간 합계 \(metric.localizedName) \(visiblePoints.reduce(0) { $0 + metric.value($1) })")
                .font(.body.weight(.semibold))
        }
        .accessibilityElement(children: .combine)
    }

    private var visibleRangeText: String {
        guard let first = visiblePoints.first?.date, let last = visiblePoints.last?.date else {
            return "좌우로 넘겨서 다른 기간을 보세요."
        }
        let start = Self.axisLabel(first, unit: unit)
        let end = Self.axisLabel(last, unit: unit)
        return start == end ? start : "\(start) ~ \(end)"
    }

    /// 탭했을 때 보여줄 정확한 날짜 (축 라벨과 달리 연도를 살린다).
    private static func fullLabel(_ date: Date, unit: UsageReportingService.BucketUnit) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        switch unit {
        case .day:
            formatter.setLocalizedDateFormatFromTemplate("yMMMd")
            return formatter.string(from: date)
        case .week:
            formatter.setLocalizedDateFormatFromTemplate("yMMMd")
            return formatter.string(from: date) + " 주 시작"
        case .month:
            formatter.setLocalizedDateFormatFromTemplate("yMMMM")
            return formatter.string(from: date)
        case .year:
            formatter.setLocalizedDateFormatFromTemplate("y")
            return formatter.string(from: date)
        }
    }

    private static func axisLabel(_ date: Date, unit: UsageReportingService.BucketUnit) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        switch unit {
        case .day, .week: formatter.setLocalizedDateFormatFromTemplate("Md")
        case .month: formatter.setLocalizedDateFormatFromTemplate("yMMM")
        case .year: formatter.setLocalizedDateFormatFromTemplate("y")
        }
        return formatter.string(from: date)
    }

    /// 가장 최근 구간이 보이도록 스크롤 위치를 옮긴다.
    private func scrollToLatest() {
        guard let last = points.last?.date else { return }
        scrollPosition = last.addingTimeInterval(-visibleDomain + 1)
    }
}
