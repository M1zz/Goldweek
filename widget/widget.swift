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
        VStack(alignment: .leading, spacing: 8) {
            // 헤더
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.caption)
                    .foregroundStyle(blueColor)
                Text("휴가캘린더")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 남은 연차
            VStack(alignment: .leading, spacing: 2) {
                Text("남은 연차")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(String(format: "%.1f", totalAvailable))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(greenColor)
                    Text("일")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // 보너스 표시
            if entry.data.bonusLeave > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "gift.fill")
                        .font(.caption2)
                        .foregroundStyle(orangeColor)
                    Text("+\(String(format: "%.1f", entry.data.bonusLeave))")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(orangeColor)
                }
            }

            Spacer()

            // 프로그레스 바
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(blueColor)
                        .frame(width: geo.size.width * entry.data.usagePercentage, height: 6)
                }
            }
            .frame(height: 6)

            Text("\(Int(entry.data.usagePercentage * 100))% 사용")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
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
        HStack(spacing: 16) {
            // 왼쪽: 남은 연차
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(blueColor)
                    Text("휴가캘린더")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text("남은 연차")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(String(format: "%.1f", totalAvailable))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(greenColor)
                        Text("일")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }

                if entry.data.bonusLeave > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.caption)
                            .foregroundStyle(orangeColor)
                        Text("보너스 +\(String(format: "%.1f", entry.data.bonusLeave))일")
                            .font(.caption)
                            .foregroundStyle(orangeColor)
                    }
                }

                Spacer()
            }

            Divider()

            // 오른쪽: 다가오는 휴가 & 통계
            VStack(alignment: .leading, spacing: 12) {
                // 다가오는 휴가
                VStack(alignment: .leading, spacing: 4) {
                    Text("다가오는 휴가")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let nextDate = entry.data.nextLeaveDate,
                       let nextType = entry.data.nextLeaveType {
                        HStack {
                            Image(systemName: "airplane.departure")
                                .foregroundStyle(blueColor)
                            VStack(alignment: .leading) {
                                Text(nextType)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(nextDate, format: .dateTime.month().day())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Text("예정된 휴가 없음")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // 사용률
                VStack(alignment: .leading, spacing: 4) {
                    Text("연차 사용률")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(blueColor)
                                .frame(width: geo.size.width * entry.data.usagePercentage, height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(entry.data.usagePercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(blueColor)
                }
            }
        }
        .padding()
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

    var body: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: 1 - entry.data.usagePercentage) {
                Image(systemName: "calendar")
            } currentValueLabel: {
                Text(String(format: "%.1f", totalAvailable))
                    .font(.system(.body, design: .rounded))
            }
            .gaugeStyle(.accessoryCircular)

        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                    Text("남은 연차")
                }
                .font(.caption)

                Text("\(String(format: "%.1f", totalAvailable))일")
                    .font(.title2)
                    .fontWeight(.bold)

                ProgressView(value: 1 - entry.data.usagePercentage)
            }

        case .accessoryInline:
            HStack {
                Image(systemName: "calendar")
                Text("남은 연차 \(String(format: "%.1f", totalAvailable))일")
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
