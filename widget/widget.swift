//
//  widget.swift
//  휴가캘린더 위젯
//

import WidgetKit
import SwiftUI

// MARK: - 위젯 데이터

struct LeaveWidgetData {
    let remainingLeave: Double
    let totalLeave: Double
    let bonusLeave: Double
    let nextLeaveDate: Date?
    let nextLeaveType: String?
    let nextLeaveNote: String?
    let nextLeaveDuration: Int       // 다음 휴가 기간 (일)
    let daysUntilNextLeave: Int      // -1 = 예정 없음, 0 = 오늘, N = N일 후
    let remainingPercentage: Double
    let userName: String

    // 소진 속도 관련
    let elapsedRatio: Double
    let actualUsedRatio: Double
    let burnRate: Double
    let remainingDays: Int

    var totalAvailable: Double { remainingLeave + bonusLeave }

    var hasUpcomingLeave: Bool { daysUntilNextLeave >= 0 }

    /// 설레는 D-day 문구
    var ddayLabel: String {
        switch daysUntilNextLeave {
        case 0:  return "D-DAY"
        case 1:  return "D-1"
        default: return "D-\(daysUntilNextLeave)"
        }
    }

    /// 상황별 감성 메시지
    var anticipationMessage: String {
        guard hasUpcomingLeave else { return "휴가 계획을 세워볼까요?" }
        switch daysUntilNextLeave {
        case 0:        return "🎉 오늘이에요!"
        case 1:        return "내일이에요!"
        case 2...3:    return "곧 시작해요 ✈️"
        case 4...7:    return "이번 주 안에!"
        case 8...14:   return "다음 주에요"
        case 15...30:  return "이번 달이에요"
        default:       return "기다리고 있어요"
        }
    }

    static let placeholder = LeaveWidgetData(
        remainingLeave: 10.0,
        totalLeave: 15.0,
        bonusLeave: 2.0,
        nextLeaveDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
        nextLeaveType: "annual",
        nextLeaveNote: "제주도 여행",
        nextLeaveDuration: 3,
        daysUntilNextLeave: 5,
        remainingPercentage: 0.67,
        userName: "홍길동",
        elapsedRatio: 0.5,
        actualUsedRatio: 0.33,
        burnRate: 0.66,
        remainingDays: 180
    )

    static func load() -> LeaveWidgetData {
        guard let defaults = UserDefaults(suiteName: "group.com.Ysoup.LeaveWise") else {
            return .placeholder
        }
        let hasData = defaults.object(forKey: "totalLeave") != nil
        guard hasData else { return .placeholder }

        let remaining  = defaults.double(forKey: "remainingLeave")
        let total      = defaults.double(forKey: "totalLeave")
        let bonus      = defaults.double(forKey: "bonusLeave")
        let percentage = total > 0 ? remaining / total : 0
        let nextDate   = defaults.object(forKey: "nextLeaveDate") as? Date
        let nextType   = defaults.string(forKey: "nextLeaveType")
        let nextNote   = defaults.string(forKey: "nextLeaveNote")
        let duration   = defaults.integer(forKey: "nextLeaveDuration")
        let daysUntil  = defaults.object(forKey: "daysUntilNextLeave") != nil
                         ? defaults.integer(forKey: "daysUntilNextLeave") : -1
        let userName   = defaults.string(forKey: "userName") ?? ""

        let elapsedRatio    = defaults.double(forKey: "elapsedRatio")
        let actualUsedRatio = defaults.double(forKey: "actualUsedRatio")
        let burnRate        = defaults.double(forKey: "burnRate")
        let remainingDays   = defaults.integer(forKey: "remainingDaysUntilReset")

        return LeaveWidgetData(
            remainingLeave: remaining,
            totalLeave: total,
            bonusLeave: bonus,
            nextLeaveDate: nextDate,
            nextLeaveType: nextType,
            nextLeaveNote: nextNote,
            nextLeaveDuration: duration,
            daysUntilNextLeave: daysUntil,
            remainingPercentage: percentage,
            userName: userName,
            elapsedRatio: elapsedRatio,
            actualUsedRatio: actualUsedRatio,
            burnRate: burnRate > 0 ? burnRate : 1.0,
            remainingDays: remainingDays
        )
    }
}

// MARK: - Timeline Provider

struct LeaveWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LeaveWidgetEntry {
        LeaveWidgetEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (LeaveWidgetEntry) -> Void) {
        completion(LeaveWidgetEntry(date: Date(), data: LeaveWidgetData.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LeaveWidgetEntry>) -> Void) {
        let data  = LeaveWidgetData.load()
        let entry = LeaveWidgetEntry(date: Date(), data: data)
        // 자정마다 D-day 숫자 갱신
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
}

struct LeaveWidgetEntry: TimelineEntry {
    let date: Date
    let data: LeaveWidgetData
}

// MARK: - 공통 색상

private let greenColor  = Color(red: 0.15, green: 0.68, blue: 0.38)
private let blueColor   = Color(red: 0.0,  green: 0.4,  blue: 0.9)
private let orangeColor = Color(red: 0.95, green: 0.5,  blue: 0.0)
private let redColor    = Color(red: 0.9,  green: 0.2,  blue: 0.2)
private let goldColor   = Color(red: 1.0,  green: 0.75, blue: 0.0)

// MARK: - D-Day 위젯 (Small)

struct DDaySmallView: View {
    var entry: LeaveWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack(spacing: 3) {
                Image(systemName: "airplane.departure")
                    .font(.system(size: 9))
                    .foregroundStyle(blueColor)
                Text("다음 휴가")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, 6)

            if entry.data.hasUpcomingLeave {
                // D-day 숫자 — 히어로
                Text(entry.data.ddayLabel)
                    .font(.system(size: entry.data.daysUntilNextLeave == 0 ? 26 : 32,
                                  weight: .black, design: .rounded))
                    .foregroundStyle(ddayColor)
                    .minimumScaleFactor(0.7)

                // 감성 메시지
                Text(entry.data.anticipationMessage)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)

                Spacer(minLength: 4)

                // 날짜 & 기간
                if let nextDate = entry.data.nextLeaveDate {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(nextDate, format: .dateTime.month().day().weekday())
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.primary)
                        if entry.data.nextLeaveDuration > 1 {
                            Text("\(entry.data.nextLeaveDuration)일간")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                // 예정 없음
                Spacer()
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.tertiary)
                Text("휴가 미정")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
                Spacer()
            }

            Spacer(minLength: 0)

            // 하단: 남은 연차
            Divider().padding(.vertical, 4)
            HStack(spacing: 2) {
                Image(systemName: "suitcase.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(greenColor)
                Text("남은 연차 \(formatDays(entry.data.totalAvailable))일")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(greenColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
    }

    private var ddayColor: Color {
        switch entry.data.daysUntilNextLeave {
        case 0:    return goldColor
        case 1...3: return blueColor
        default:   return greenColor
        }
    }
}

// MARK: - D-Day 위젯 (Medium)

struct DDayMediumView: View {
    var entry: LeaveWidgetEntry

    var body: some View {
        HStack(spacing: 0) {
            // 왼쪽: D-Day 히어로
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 3) {
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 10))
                        .foregroundStyle(blueColor)
                    Text("다음 휴가")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                if entry.data.hasUpcomingLeave {
                    Text(entry.data.ddayLabel)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(ddayColor)
                        .minimumScaleFactor(0.6)

                    Text(entry.data.anticipationMessage)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                } else {
                    Spacer()
                    Text("휴가 미정")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Spacer()
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 구분선
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 6)

            // 오른쪽: 세부 정보
            VStack(alignment: .leading, spacing: 0) {
                // 날짜 & 기간
                if let nextDate = entry.data.nextLeaveDate, entry.data.hasUpcomingLeave {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(nextDate, format: .dateTime.month().day().weekday())
                            .font(.system(size: 12, weight: .semibold))
                        if let note = entry.data.nextLeaveNote, !note.isEmpty {
                            Text(note)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        if entry.data.nextLeaveDuration > 1 {
                            HStack(spacing: 3) {
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(blueColor)
                                Text("\(entry.data.nextLeaveDuration)일간")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(blueColor)
                            }
                        }
                    }
                }

                Spacer(minLength: 6)

                // 남은 연차 현황
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("남은 연차")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(formatDays(entry.data.totalAvailable))일")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(greenColor)
                    }
                    ProgressView(value: min(max(entry.data.remainingPercentage, 0), 1))
                        .progressViewStyle(.linear)
                        .tint(greenColor)
                    Text("\(Int(entry.data.remainingPercentage * 100))% 남음")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
    }

    private var ddayColor: Color {
        switch entry.data.daysUntilNextLeave {
        case 0:    return goldColor
        case 1...3: return blueColor
        default:   return greenColor
        }
    }
}

// MARK: - D-Day 위젯 정의

struct DDayWidget: Widget {
    let kind: String = "DDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeaveWidgetProvider()) { entry in
            DDayWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("휴가 D-Day")
        .description("다음 휴가까지 남은 날을 카운트다운으로 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DDayWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LeaveWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:  DDaySmallView(entry: entry)
        case .systemMedium: DDayMediumView(entry: entry)
        default:            DDaySmallView(entry: entry)
        }
    }
}

// MARK: - 기존 연차 위젯 (Small)

struct LeaveWidgetSmallView: View {
    var entry: LeaveWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 3) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 10))
                    .foregroundStyle(blueColor)
                Text("연차 현황")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 2) {
                Text("남은 연차")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(formatDays(entry.data.totalAvailable))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(greenColor)
                        .minimumScaleFactor(0.8)
                    Text("일")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            if entry.data.bonusLeave > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(orangeColor)
                    Text("+\(formatDays(entry.data.bonusLeave))일")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(orangeColor)
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 4)

            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: min(max(entry.data.remainingPercentage, 0), 1))
                    .progressViewStyle(.linear)
                    .tint(greenColor)
                Text("\(Int(entry.data.remainingPercentage * 100))% 남음")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
    }
}

// MARK: - 기존 연차 위젯 (Medium)

struct LeaveWidgetMediumView: View {
    var entry: LeaveWidgetEntry

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 3) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 11))
                        .foregroundStyle(blueColor)
                    Text("연차 현황")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                Text("남은 연차")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 2)

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(formatDays(entry.data.totalAvailable))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(greenColor)
                        .minimumScaleFactor(0.8)
                    Text("일")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                if entry.data.bonusLeave > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(orangeColor)
                        Text("+\(formatDays(entry.data.bonusLeave))일")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(orangeColor)
                    }
                    .padding(.top, 4)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 6)

            VStack(alignment: .leading, spacing: 0) {
                // D-day or 다가오는 휴가
                VStack(alignment: .leading, spacing: 4) {
                    Text("다가오는 휴가")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)

                    if entry.data.hasUpcomingLeave, let nextDate = entry.data.nextLeaveDate {
                        HStack(spacing: 4) {
                            Text(entry.data.ddayLabel)
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(blueColor)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(nextDate, format: .dateTime.month().day())
                                    .font(.system(size: 11, weight: .medium))
                                if entry.data.nextLeaveDuration > 1 {
                                    Text("\(entry.data.nextLeaveDuration)일간")
                                        .font(.system(size: 9))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "moon.zzz")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
                            Text("휴가 없음")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Spacer(minLength: 8)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("잔여율")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(entry.data.remainingPercentage * 100))%")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(greenColor)
                    }
                    ProgressView(value: min(max(entry.data.remainingPercentage, 0), 1))
                        .progressViewStyle(.linear)
                        .tint(greenColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
    }
}

// MARK: - 연차 현황 위젯 (Large)

struct LeaveWidgetLargeView: View {
    var entry: LeaveWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(blueColor)
                    Text("LeaveWise")
                        .font(.system(size: 13, weight: .bold))
                }
                Spacer()
                Text("\(formatDays(entry.data.totalAvailable))일 남음")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(greenColor)
            }
            .padding(.bottom, 10)

            // D-Day 섹션
            if entry.data.hasUpcomingLeave {
                HStack(alignment: .bottom, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.data.ddayLabel)
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(ddayColor)
                            .minimumScaleFactor(0.6)
                        Text(entry.data.anticipationMessage)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let nextDate = entry.data.nextLeaveDate {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(nextDate, format: .dateTime.month().day().weekday())
                                .font(.system(size: 13, weight: .semibold))
                            if entry.data.nextLeaveDuration > 1 {
                                HStack(spacing: 3) {
                                    Image(systemName: "moon.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(blueColor)
                                    Text("\(entry.data.nextLeaveDuration)일간")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(blueColor)
                                }
                            }
                            if let note = entry.data.nextLeaveNote, !note.isEmpty {
                                Text(note)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ddayColor.opacity(0.08))
                )
            } else {
                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(blueColor)
                    Text("앱에서 휴가 계획을 추가해보세요")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 12)
            }

            // 연차 현황 바
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("연차 현황")
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Text("\(Int(entry.data.remainingPercentage * 100))%")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(greenColor)
                }
                .padding(.top, 10)

                ProgressView(value: min(max(entry.data.remainingPercentage, 0), 1))
                    .progressViewStyle(.linear)
                    .tint(progressColor)
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("총 연차")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text("\(Int(entry.data.totalLeave))일")
                            .font(.system(size: 12, weight: .bold))
                    }
                    Spacer()
                    VStack(alignment: .center, spacing: 2) {
                        Text("남은 연차")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text("\(formatDays(entry.data.remainingLeave))일")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(greenColor)
                    }
                    Spacer()
                    if entry.data.bonusLeave > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("보너스")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                            Text("+\(formatDays(entry.data.bonusLeave))일")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(orangeColor)
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("갱신까지")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                            Text("\(entry.data.remainingDays)일")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // 소진 속도
            Divider().padding(.vertical, 8)
            HStack(spacing: 6) {
                Image(systemName: burnRateIcon)
                    .font(.system(size: 12))
                    .foregroundStyle(burnRateColor)
                Text("소진 속도: \(burnRateText)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(burnRateColor)
                Spacer()
                Text("갱신까지 \(entry.data.remainingDays)일")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
    }

    private var ddayColor: Color {
        switch entry.data.daysUntilNextLeave {
        case 0:     return goldColor
        case 1...3: return blueColor
        default:    return greenColor
        }
    }

    private var progressColor: Color {
        let pct = entry.data.remainingPercentage
        if pct > 0.5 { return greenColor }
        if pct > 0.25 { return orangeColor }
        return redColor
    }

    private var burnRateText: String {
        let r = entry.data.burnRate
        if r < 0.7 { return "느림" }
        if r < 0.9 { return "조금 느림" }
        if r <= 1.1 { return "적정 ✓" }
        if r <= 1.3 { return "조금 빠름" }
        return "빠름"
    }
    private var burnRateIcon: String {
        let r = entry.data.burnRate
        if r < 0.9 { return "tortoise.fill" }
        if r <= 1.1 { return "checkmark.circle.fill" }
        return "flame.fill"
    }
    private var burnRateColor: Color {
        let r = entry.data.burnRate
        if r < 0.9 { return orangeColor }
        if r <= 1.1 { return greenColor }
        return redColor
    }
}

// MARK: - 기존 연차 위젯 정의

struct LeaveWidget: Widget {
    let kind: String = "LeaveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeaveWidgetProvider()) { entry in
            LeaveWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("연차 현황")
        .description("남은 연차와 다가오는 휴가를 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct LeaveWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LeaveWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:  LeaveWidgetSmallView(entry: entry)
        case .systemMedium: LeaveWidgetMediumView(entry: entry)
        case .systemLarge:  LeaveWidgetLargeView(entry: entry)
        default:            LeaveWidgetSmallView(entry: entry)
        }
    }
}

// MARK: - 잠금화면 위젯 (강화)

struct LeaveAccessoryWidget: Widget {
    let kind: String = "LeaveAccessoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeaveWidgetProvider()) { entry in
            LeaveAccessoryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("남은 연차")
        .description("잠금화면에서 D-day와 남은 연차를 확인하세요")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct LeaveAccessoryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LeaveWidgetEntry

    var gauge: Double { min(max(entry.data.remainingPercentage, 0), 1) }

    var body: some View {
        switch family {
        case .accessoryCircular:
            accessoryCircularView

        case .accessoryRectangular:
            accessoryRectangularView

        case .accessoryInline:
            accessoryInlineView

        default:
            Text(String(format: "%.0f", entry.data.totalAvailable))
        }
    }

    // 원형: D-day가 있으면 카운트다운, 없으면 남은 연차
    private var accessoryCircularView: some View {
        Group {
            if entry.data.hasUpcomingLeave {
                ZStack {
                    Gauge(value: gauge) {
                        Image(systemName: "airplane")
                    }
                    .gaugeStyle(.accessoryCircularCapacity)

                    VStack(spacing: 0) {
                        Text("D-")
                            .font(.system(size: 7, weight: .bold, design: .rounded))
                        Text("\(entry.data.daysUntilNextLeave == 0 ? "★" : "\(entry.data.daysUntilNextLeave)")")
                            .font(.system(size: entry.data.daysUntilNextLeave < 10 ? 16 : 13,
                                          weight: .black, design: .rounded))
                    }
                }
            } else {
                Gauge(value: gauge) {
                    Image(systemName: "calendar")
                } currentValueLabel: {
                    Text(String(format: "%.0f", entry.data.totalAvailable))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .gaugeStyle(.accessoryCircularCapacity)
            }
        }
    }

    // 직사각형: D-day + 날짜 + 남은 연차
    private var accessoryRectangularView: some View {
        VStack(alignment: .leading, spacing: 3) {
            if entry.data.hasUpcomingLeave {
                HStack(spacing: 5) {
                    Text(entry.data.ddayLabel)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                    if let nextDate = entry.data.nextLeaveDate {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(nextDate, format: .dateTime.month().day())
                                .font(.system(size: 11, weight: .semibold))
                            if entry.data.nextLeaveDuration > 1 {
                                Text("\(entry.data.nextLeaveDuration)일간")
                                    .font(.system(size: 9))
                            }
                        }
                    }
                }
                ProgressView(value: gauge)
                    .progressViewStyle(.linear)
                HStack(spacing: 3) {
                    Image(systemName: "suitcase")
                        .font(.system(size: 9))
                    Text("남은 연차 \(formatDays(entry.data.totalAvailable))일")
                        .font(.system(size: 10, weight: .medium))
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 12))
                    Text("남은 연차")
                        .font(.system(size: 12, weight: .medium))
                }
                Text("\(formatDays(entry.data.totalAvailable))일")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                ProgressView(value: gauge)
                    .progressViewStyle(.linear)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // 인라인: 가장 중요한 한 줄 (Label만 허용)
    private var accessoryInlineView: some View {
        Label {
            Text(entry.data.hasUpcomingLeave
                 ? "\(entry.data.ddayLabel) · 연차 \(formatDays(entry.data.totalAvailable))일"
                 : "연차 \(formatDays(entry.data.totalAvailable))일 남음")
        } icon: {
            Image(systemName: entry.data.hasUpcomingLeave ? "airplane.departure" : "calendar")
        }
    }
}

// MARK: - 소진 속도 위젯

struct BurnRateWidget: Widget {
    let kind: String = "BurnRateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeaveWidgetProvider()) { entry in
            BurnRateWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("연차 소진 속도")
        .description("연차 갱신일까지 소진 속도를 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}

struct BurnRateWidgetView: View {
    var entry: LeaveWidgetEntry

    var burnRateStatus: (color: Color, icon: String, text: String) {
        let rate = entry.data.burnRate
        if rate < 0.7        { return (redColor,    "tortoise.fill",              "느림") }
        else if rate < 0.9   { return (orangeColor, "hare.fill",                  "조금 느림") }
        else if rate <= 1.1  { return (greenColor,  "checkmark.circle.fill",      "적정") }
        else if rate <= 1.3  { return (orangeColor, "exclamationmark.triangle.fill", "조금 빠름") }
        else                 { return (redColor,    "flame.fill",                 "빠름") }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 3) {
                Image(systemName: "speedometer")
                    .font(.system(size: 10))
                    .foregroundStyle(blueColor)
                Text("소진 속도")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, 6)

            HStack(spacing: 4) {
                Image(systemName: burnRateStatus.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(burnRateStatus.color)
                Text(burnRateStatus.text)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(burnRateStatus.color)
            }
            .padding(.bottom, 6)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("기준")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, alignment: .leading)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.gray.opacity(0.2))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: geo.size.width * entry.data.elapsedRatio)
                        }
                    }
                    .frame(height: 6)
                    Text("\(Int(entry.data.elapsedRatio * 100))%")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, alignment: .trailing)
                }
                HStack(spacing: 4) {
                    Text("실제")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, alignment: .leading)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.gray.opacity(0.2))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(burnRateStatus.color)
                                .frame(width: geo.size.width * min(entry.data.actualUsedRatio, 1.0))
                        }
                    }
                    .frame(height: 6)
                    Text("\(Int(entry.data.actualUsedRatio * 100))%")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, alignment: .trailing)
                }
            }

            Spacer(minLength: 4)

            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("남은 연차")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                    Text("\(formatDays(entry.data.remainingLeave))일")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(greenColor)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text("갱신까지")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                    Text("\(entry.data.remainingDays)일")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(blueColor)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(12)
    }
}

// MARK: - 헬퍼

private func formatDays(_ days: Double) -> String {
    days == Double(Int(days)) ? "\(Int(days))" : String(format: "%.1f", days)
}

// MARK: - 프리뷰

#Preview(as: .systemSmall) {
    DDayWidget()
} timeline: {
    LeaveWidgetEntry(date: .now, data: .placeholder)
}

#Preview(as: .systemMedium) {
    DDayWidget()
} timeline: {
    LeaveWidgetEntry(date: .now, data: .placeholder)
}

#Preview(as: .systemSmall) {
    LeaveWidget()
} timeline: {
    LeaveWidgetEntry(date: .now, data: .placeholder)
}

#Preview(as: .systemMedium) {
    LeaveWidget()
} timeline: {
    LeaveWidgetEntry(date: .now, data: .placeholder)
}

#Preview(as: .systemLarge) {
    LeaveWidget()
} timeline: {
    LeaveWidgetEntry(date: .now, data: .placeholder)
}

#Preview(as: .accessoryCircular) {
    LeaveAccessoryWidget()
} timeline: {
    LeaveWidgetEntry(date: .now, data: .placeholder)
}

#Preview(as: .accessoryRectangular) {
    LeaveAccessoryWidget()
} timeline: {
    LeaveWidgetEntry(date: .now, data: .placeholder)
}

#Preview(as: .systemSmall) {
    BurnRateWidget()
} timeline: {
    LeaveWidgetEntry(date: .now, data: .placeholder)
}
