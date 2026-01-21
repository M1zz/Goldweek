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
    let remainingPercentage: Double

    // 소진 속도 관련
    let elapsedRatio: Double      // 기간 경과율 (0~1)
    let actualUsedRatio: Double   // 실제 사용률 (0~1)
    let burnRate: Double          // 소진 속도 (1.0=적정, <1=느림, >1=빠름)
    let remainingDays: Int        // 갱신일까지 남은 일수

    static let placeholder = LeaveWidgetData(
        remainingLeave: 10.0,
        totalLeave: 15.0,
        bonusLeave: 2.0,
        nextLeaveDate: nil,
        nextLeaveType: nil,
        remainingPercentage: 0.67,
        elapsedRatio: 0.5,
        actualUsedRatio: 0.33,
        burnRate: 0.66,
        remainingDays: 180
    )

    static func load() -> LeaveWidgetData {
        guard let defaults = UserDefaults(suiteName: "group.com.Ysoup.LeaveWise") else {
            return .placeholder
        }

        // 데이터가 한 번도 저장된 적 없으면 placeholder 반환
        let hasData = defaults.object(forKey: "totalLeave") != nil
        guard hasData else {
            return .placeholder
        }

        let remaining = defaults.double(forKey: "remainingLeave")
        let total = defaults.double(forKey: "totalLeave")
        let bonus = defaults.double(forKey: "bonusLeave")
        let nextDate = defaults.object(forKey: "nextLeaveDate") as? Date
        let nextType = defaults.string(forKey: "nextLeaveType")
        let percentage = total > 0 ? remaining / total : 0

        // 소진 속도 데이터
        let elapsedRatio = defaults.double(forKey: "elapsedRatio")
        let actualUsedRatio = defaults.double(forKey: "actualUsedRatio")
        let burnRate = defaults.double(forKey: "burnRate")
        let remainingDays = defaults.integer(forKey: "remainingDaysUntilReset")

        return LeaveWidgetData(
            remainingLeave: remaining,
            totalLeave: total,
            bonusLeave: bonus,
            nextLeaveDate: nextDate,
            nextLeaveType: nextType,
            remainingPercentage: percentage,
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
            HStack(spacing: 3) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 10))
                    .foregroundStyle(blueColor)
                Text("휴가")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, 8)

            // 남은 연차
            VStack(alignment: .leading, spacing: 2) {
                Text("남은 연차")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(String(format: "%.1f", totalAvailable))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(greenColor)
                        .minimumScaleFactor(0.8)
                    Text("일")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            // 보너스 표시
            if entry.data.bonusLeave > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(orangeColor)
                    Text("+\(String(format: "%.1f", entry.data.bonusLeave))일")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(orangeColor)
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 4)

            // 프로그레스 바
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: entry.data.remainingPercentage)
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
                HStack(spacing: 3) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 11))
                        .foregroundStyle(blueColor)
                    Text("휴가")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                Text("남은 연차")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 2)

                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(String(format: "%.1f", totalAvailable))
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
                        Text("+\(String(format: "%.1f", entry.data.bonusLeave))일")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(orangeColor)
                    }
                    .padding(.top, 4)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 구분선
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 6)

            // 오른쪽: 다가오는 휴가 & 통계
            VStack(alignment: .leading, spacing: 0) {
                // 다가오는 휴가
                VStack(alignment: .leading, spacing: 4) {
                    Text("다가오는 휴가")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)

                    if let nextDate = entry.data.nextLeaveDate,
                       let nextType = entry.data.nextLeaveType {
                        HStack(spacing: 4) {
                            Image(systemName: "airplane.departure")
                                .font(.system(size: 11))
                                .foregroundStyle(blueColor)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(nextType)
                                    .font(.system(size: 11, weight: .medium))
                                    .lineLimit(1)
                                Text(nextDate, format: .dateTime.month().day())
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
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

                // 잔여율
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

                    ProgressView(value: entry.data.remainingPercentage)
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
        min(max(entry.data.remainingPercentage, 0), 1)
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

// MARK: - 소진 속도 위젯
struct BurnRateWidget: Widget {
    let kind: String = "BurnRateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LeaveWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                BurnRateWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                BurnRateWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("연차 소진 속도")
        .description("연차 갱신일까지 소진 속도를 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}

struct BurnRateWidgetView: View {
    var entry: LeaveWidgetEntry

    private let greenColor = Color(red: 0.15, green: 0.68, blue: 0.38)
    private let blueColor = Color(red: 0.0, green: 0.4, blue: 0.9)
    private let orangeColor = Color(red: 0.95, green: 0.5, blue: 0.0)
    private let redColor = Color(red: 0.9, green: 0.2, blue: 0.2)

    var burnRateStatus: (color: Color, icon: String, text: String) {
        let rate = entry.data.burnRate
        if rate < 0.7 {
            return (redColor, "tortoise.fill", "느림")
        } else if rate < 0.9 {
            return (orangeColor, "hare.fill", "조금 느림")
        } else if rate <= 1.1 {
            return (greenColor, "checkmark.circle.fill", "적정")
        } else if rate <= 1.3 {
            return (orangeColor, "exclamationmark.triangle.fill", "조금 빠름")
        } else {
            return (redColor, "flame.fill", "빠름")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
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

            // 상태 표시
            HStack(spacing: 4) {
                Image(systemName: burnRateStatus.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(burnRateStatus.color)
                Text(burnRateStatus.text)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(burnRateStatus.color)
            }
            .padding(.bottom, 6)

            // 비교 바
            VStack(alignment: .leading, spacing: 4) {
                // 이상적 사용률 (기간 경과율)
                HStack(spacing: 4) {
                    Text("기준")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, alignment: .leading)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
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

                // 실제 사용률
                HStack(spacing: 4) {
                    Text("실제")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, alignment: .leading)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
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

            // 하단 정보
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("남은 연차")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                    Text("\(String(format: "%.1f", entry.data.remainingLeave))일")
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

#Preview(as: .systemSmall) {
    BurnRateWidget()
} timeline: {
    LeaveWidgetEntry(date: .now, data: .placeholder)
}
