//
//  widget.swift
//  휴가캘린더 위젯
//
//  남은 연차와 다가오는 휴가를 표시하는 위젯
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
    let usagePercentage: Double

    static let placeholder = LeaveWidgetData(
        remainingLeave: 10.0,
        totalLeave: 15.0,
        bonusLeave: 2.0,
        nextLeaveDate: nil,
        nextLeaveType: nil,
        usagePercentage: 0.33
    )

    static func load() -> LeaveWidgetData {
        let defaults = UserDefaults(suiteName: "group.com.Ysoup.LeaveWise")

        let remaining = defaults?.double(forKey: "remainingLeave") ?? 15.0
        let total = defaults?.double(forKey: "totalLeave") ?? 15.0
        let bonus = defaults?.double(forKey: "bonusLeave") ?? 0.0
        let nextDate = defaults?.object(forKey: "nextLeaveDate") as? Date
        let nextType = defaults?.string(forKey: "nextLeaveType")
        let used = defaults?.double(forKey: "usedLeave") ?? 0.0
        let percentage = total > 0 ? used / total : 0

        return LeaveWidgetData(
            remainingLeave: remaining,
            totalLeave: total,
            bonusLeave: bonus,
            nextLeaveDate: nextDate,
            nextLeaveType: nextType,
            usagePercentage: percentage
        )
    }
}

// MARK: - Timeline Provider
struct LeaveWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LeaveWidgetEntry {
        LeaveWidgetEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (LeaveWidgetEntry) -> Void) {
        let entry = LeaveWidgetEntry(date: Date(), data: LeaveWidgetData.load())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LeaveWidgetEntry>) -> Void) {
        let currentDate = Date()
        let data = LeaveWidgetData.load()
        let entry = LeaveWidgetEntry(date: currentDate, data: data)

        // 하루에 한 번 갱신
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct LeaveWidgetEntry: TimelineEntry {
    let date: Date
    let data: LeaveWidgetData
}

// MARK: - 위젯 뷰 (Small)
struct LeaveWidgetSmallView: View {
    var entry: LeaveWidgetEntry

    private let greenColor = Color(red: 0.15, green: 0.68, blue: 0.38)
    private let blueColor = Color(red: 0.0, green: 0.4, blue: 0.9)
    private let orangeColor = Color(red: 0.95, green: 0.5, blue: 0.0)

    var totalAvailable: Double {
        entry.data.remainingLeave + entry.data.bonusLeave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            HStack(spacing: 4) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 12))
                    .foregroundStyle(blueColor)
                Text("휴가캘린더")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, 12)

            // 남은 연차
            VStack(alignment: .leading, spacing: 4) {
                Text("남은 연차")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(String(format: "%.1f", totalAvailable))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(greenColor)
                    Text("일")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            // 보너스 표시
            if entry.data.bonusLeave > 0 {
                HStack(spacing: 3) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(orangeColor)
                    Text("보너스 +\(String(format: "%.1f", entry.data.bonusLeave))일")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(orangeColor)
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 8)

            // 프로그레스 바
            VStack(alignment: .leading, spacing: 6) {
                ProgressView(value: entry.data.usagePercentage)
                    .progressViewStyle(.linear)
                    .tint(blueColor)

                Text("\(Int(entry.data.usagePercentage * 100))% 사용")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
    }
}

// MARK: - 위젯 뷰 (Medium)
struct LeaveWidgetMediumView: View {
    var entry: LeaveWidgetEntry

    private let greenColor = Color(red: 0.15, green: 0.68, blue: 0.38)
    private let blueColor = Color(red: 0.0, green: 0.4, blue: 0.9)
    private let orangeColor = Color(red: 0.95, green: 0.5, blue: 0.0)

    var totalAvailable: Double {
        entry.data.remainingLeave + entry.data.bonusLeave
    }

    var body: some View {
        HStack(spacing: 0) {
            // 왼쪽: 남은 연차
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 14))
                        .foregroundStyle(blueColor)
                    Text("휴가캘린더")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 12)

                Text("남은 연차")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(String(format: "%.1f", totalAvailable))
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(greenColor)
                    Text("일")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                if entry.data.bonusLeave > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(orangeColor)
                        Text("보너스 +\(String(format: "%.1f", entry.data.bonusLeave))일")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(orangeColor)
                    }
                    .padding(.top, 6)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 구분선
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 8)

            // 오른쪽: 다가오는 휴가 & 통계
            VStack(alignment: .leading, spacing: 0) {
                // 다가오는 휴가
                VStack(alignment: .leading, spacing: 6) {
                    Text("다가오는 휴가")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    if let nextDate = entry.data.nextLeaveDate,
                       let nextType = entry.data.nextLeaveType {
                        HStack(spacing: 6) {
                            Image(systemName: "airplane.departure")
                                .font(.system(size: 14))
                                .foregroundStyle(blueColor)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(nextType)
                                    .font(.system(size: 13, weight: .medium))
                                Text(nextDate, format: .dateTime.month().day())
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "moon.zzz")
                                .font(.system(size: 14))
                                .foregroundStyle(.tertiary)
                            Text("예정된 휴가 없음")
                                .font(.system(size: 12))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Spacer(minLength: 12)

                // 사용률
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("연차 사용률")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(entry.data.usagePercentage * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(blueColor)
                    }

                    ProgressView(value: entry.data.usagePercentage)
                        .progressViewStyle(.linear)
                        .tint(blueColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(14)
    }
}

// MARK: - 위젯 정의
struct LeaveWidget: Widget {
    let kind: String = "LeaveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeaveWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                LeaveWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LeaveWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("휴가캘린더")
        .description("남은 연차와 다가오는 휴가를 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct LeaveWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LeaveWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            LeaveWidgetSmallView(entry: entry)
        case .systemMedium:
            LeaveWidgetMediumView(entry: entry)
        default:
            LeaveWidgetSmallView(entry: entry)
        }
    }
}

// MARK: - 잠금화면 위젯
struct LeaveAccessoryWidget: Widget {
    let kind: String = "LeaveAccessoryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeaveWidgetProvider()) { entry in
            LeaveAccessoryView(entry: entry)
        }
        .configurationDisplayName("남은 연차")
        .description("잠금화면에서 남은 연차 확인")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct LeaveAccessoryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LeaveWidgetEntry

    var totalAvailable: Double {
        entry.data.remainingLeave + entry.data.bonusLeave
    }

    var remainingPercentage: Double {
        min(max(1 - entry.data.usagePercentage, 0), 1)
    }

    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: remainingPercentage) {
                Image(systemName: "calendar")
            } currentValueLabel: {
                Text(String(format: "%.0f", totalAvailable))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .gaugeStyle(.accessoryCircularCapacity)

        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 12))
                    Text("남은 연차")
                        .font(.system(size: 12, weight: .medium))
                }

                Text("\(String(format: "%.1f", totalAvailable))일")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                ProgressView(value: remainingPercentage)
                    .progressViewStyle(.linear)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .accessoryInline:
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                Text("연차 \(String(format: "%.1f", totalAvailable))일 남음")
            }

        default:
            Text(String(format: "%.1f", totalAvailable))
        }
    }
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
