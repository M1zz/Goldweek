//
//  PaywallShowcaseArt.swift
//  Goldweek
//
//  페이월에서 넘겨 보는 기능 그림. 스크린샷 대신 SwiftUI 로 **그 기능이 적용된 화면을 줄여** 그린다 —
//  글자는 앱 언어를, 색은 다크 모드를 따라가고, 앱 용량이 늘지 않는다(LeeoKit `LeeoShowcase`).
//
//  ⚠️ 그림 속 글자는 꼭 필요한 것만(달 이름 · 요일 · 숫자 · 날짜). 문장은 그림 아래 한 줄 설명이 맡는다.
//

import SwiftUI
import LeeoKit
import GoldweekCore

// MARK: - 페이월이 넘겨 보는 장

extension PaywallView {
    /// 등급마다 넘겨 볼 장. 프로는 프로에서 더 열리는 것만 — 플러스의 것은 플러스 칸에서 본다.
    static func showcases(of tier: ProTier) -> [LeeoShowcase] {
        switch tier {
        case .free:
            return []
        case .plus:
            return [
                LeeoShowcase(id: "planner", title: Strings.proFeatureAIAnnualPlanner,
                             detail: Strings.showcasePlannerDesc) { PlannerArt() },
                LeeoShowcase(id: "recs", title: Strings.featUnlimitedRecs,
                             detail: Strings.showcaseRecsDesc) { RecommendationsArt() },
                LeeoShowcase(id: "years", title: Strings.featOtherYears,
                             detail: Strings.showcaseYearsDesc) { OtherYearsArt() },
                LeeoShowcase(id: "calendar", title: Strings.calendarExportToggle,
                             detail: Strings.showcaseCalendarDesc) { CalendarExportArt() },
            ]
        case .pro:
            return [
                LeeoShowcase(id: "bonus", title: Strings.bonusLeaveManagement,
                             detail: Strings.showcaseBonusDesc) { BonusLeaveArt() },
                LeeoShowcase(id: "allowance", title: Strings.paywallAllowanceFeature,
                             detail: Strings.showcaseAllowanceDesc) { AllowanceArt() },
                LeeoShowcase(id: "school", title: Strings.schoolImportTitle,
                             detail: Strings.showcaseSchoolDesc) { SchoolImportArt() },
                LeeoShowcase(id: "detect", title: Strings.autoDetectSettingTitle,
                             detail: Strings.showcaseDetectDesc) { AutoDetectArt() },
                LeeoShowcase(id: "together", title: Strings.togetherTitle,
                             detail: Strings.showcaseTogetherDesc) { TogetherArt() },
                LeeoShowcase(id: "anniversary", title: Strings.familyAnniversariesTitle,
                             detail: Strings.showcaseAnniversaryDesc) { AnniversaryArt() },
            ]
        }
    }
}

// MARK: - 조각

/// 그림 속 작은 달력 한 달. 1일이 `startColumn` 번째 칸(0 = 주의 첫날)에서 시작한다.
private struct ArtMonth: View {
    var title: String?
    var days = 31
    var startColumn = 4
    /// 연차(금색)
    var leave: Set<Int> = []
    /// 공휴일(빨강)
    var holidays: Set<Int> = []
    /// 그 밖에 칠할 날과 색(방학 · 함께 쉬는 날)
    var marked: Set<Int> = []
    var markColor: Color = .teal
    /// 하트를 다는 날
    var hearts: Set<Int> = []

    private let cal = Calendar.app

    /// 격자의 칸: 요일 "w0"… · 빈칸 "p0"… · 날짜 "d1"…
    private var slots: [String] {
        (0..<7).map { "w\($0)" } + (0..<startColumn).map { "p\($0)" } + (1...days).map { "d\($0)" }
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                Text(title).font(.caption.weight(.bold)).foregroundStyle(.secondary)
            }
            // ⚠️ 요일 · 빈칸 · 날짜를 ForEach 하나로, 겹치지 않는 id 로 — 따로 두면 격자가 같은 숫자 id 칸을 빼먹는다
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(slots, id: \.self) { slot in
                    switch slot.first {
                    case "w":
                        let i = Int(slot.dropFirst()) ?? 0
                        Text(weekday(i))
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(isWeekend(column: i) ? Color.red.opacity(0.7) : .secondary)
                    case "d":
                        cell(Int(slot.dropFirst()) ?? 1)
                    default:
                        Color.clear.frame(height: 20)
                    }
                }
            }
        }
    }

    private func cell(_ day: Int) -> some View {
        let column = (startColumn + day - 1) % 7
        let fill: Color? = leave.contains(day) ? AppTheme.Colors.bonus
            : holidays.contains(day) ? .red.opacity(0.85)
            : marked.contains(day) ? markColor : nil
        return ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(fill ?? Color.clear)
            if hearts.contains(day) {
                Image(systemName: "heart.fill").font(.system(size: 10)).foregroundStyle(.pink)
            } else {
                Text(verbatim: "\(day)")
                    .font(.system(size: 10, weight: fill == nil ? .regular : .bold))
                    .foregroundStyle(fill != nil ? Color.white : isWeekend(column: column) ? Color.red.opacity(0.7) : Color.primary)
            }
        }
        .frame(height: 20)
    }

    /// 주의 i 번째 칸의 요일 글자 (앱 달력의 주 시작을 따른다)
    private func weekday(_ column: Int) -> String {
        let symbols = cal.veryShortStandaloneWeekdaySymbols
        return symbols[(cal.firstWeekday - 1 + column) % 7]
    }

    private func isWeekend(column: Int) -> Bool {
        let weekday = (cal.firstWeekday - 1 + column) % 7 + 1   // 1 = 일요일
        return weekday == 1 || weekday == 7
    }
}

/// 그림 속 카드 한 장 (앱의 카드처럼)
private struct ArtCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(12)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

/// "연차 3 → 9일" 같은 칩. 숫자와 기호만 쓴다.
private struct LeaveToRestChip: View {
    let leave: Int
    let rest: Int
    var body: some View {
        HStack(spacing: 6) {
            Label { Text(verbatim: "\(leave)") } icon: { Image(systemName: "briefcase.fill") }
                .foregroundStyle(AppTheme.Colors.bonus)
            Image(systemName: "arrow.right").font(.caption.weight(.bold)).foregroundStyle(.secondary)
            Text(Strings.quickAddRestDays(rest)).foregroundStyle(AppTheme.Colors.brand)
        }
        .font(.subheadline.weight(.bold))
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(Color(.systemBackground), in: Capsule())
        .shadow(color: .black.opacity(0.06), radius: 4, y: 1)
    }
}

private func monthName(_ month: Int) -> String {
    let f = DateFormatter()
    f.locale = Locale(identifier: Strings.localeIdentifier)
    f.setLocalizedDateFormatFromTemplate("MMMM")
    var c = DateComponents(); c.year = 2027; c.month = month; c.day = 1
    return Calendar.app.date(from: c).map(f.string(from:)) ?? ""
}

private func dateRange(month: Int, from: Int, to: Int) -> String {
    var a = DateComponents(); a.year = 2027; a.month = month; a.day = from
    var b = a; b.day = to
    guard let start = Calendar.app.date(from: a), let end = Calendar.app.date(from: b) else { return "" }
    return (start..<end).formatted(.interval.month(.abbreviated).day()
        .locale(Locale(identifier: Strings.localeIdentifier)))
}

// MARK: - 플러스

/// 연간 최적 플래너: 공휴일 사이에 연차를 놓아 길게 이어진 연휴
private struct PlannerArt: View {
    var body: some View {
        VStack(spacing: 12) {
            LeaveToRestChip(leave: 3, rest: 9)
            ArtCard {
                ArtMonth(title: monthName(5), startColumn: 6,
                         leave: [3, 4, 6], holidays: [1, 5, 7])
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(AppTheme.Colors.bonus)
                    .padding(8)
            }
        }
        .padding(16)
    }
}

/// 추천 연휴 무제한: 추천 카드가 여러 장, 모두 '넣음'
private struct RecommendationsArt: View {
    private let items: [(month: Int, from: Int, to: Int, rest: Int)] = [
        (5, 1, 9, 9), (6, 3, 7, 5), (9, 23, 28, 6), (10, 2, 11, 10),
    ]
    var body: some View {
        VStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { i in
                let item = items[i]
                ArtCard {
                    HStack(spacing: 10) {
                        Capsule().fill(AppTheme.Colors.bonus).frame(width: 4, height: 26)
                        Text(dateRange(month: item.month, from: item.from, to: item.to))
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(Strings.quickAddRestDays(item.rest))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.Colors.brand)
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    }
                }
            }
        }
        .padding(16)
    }
}

/// 다른 해: 해를 오가며 본다
private struct OtherYearsArt: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach([2026, 2027, 2028], id: \.self) { year in
                    Text(verbatim: "\(year)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(year == 2027 ? Color.primary : Color.secondary)
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background {
                            if year == 2027 {
                                Capsule().fill(Color(.systemBackground)).shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                            }
                        }
                }
            }
            .padding(3)
            .background(Color(.tertiarySystemFill), in: Capsule())
            ArtCard {
                ArtMonth(title: monthName(10), startColumn: 5, leave: [4, 5, 6], holidays: [1, 3, 9])
            }
        }
        .padding(16)
    }
}

/// 캘린더 내보내기: 골드위크의 휴가가 아이폰 캘린더에 들어간다
private struct CalendarExportArt: View {
    var body: some View {
        HStack(spacing: 14) {
            ArtCard {
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: "sun.max.fill").foregroundStyle(AppTheme.Colors.bonus)
                    Capsule().fill(AppTheme.Colors.bonus).frame(width: 70, height: 8)
                    Capsule().fill(AppTheme.Colors.bonus.opacity(0.5)).frame(width: 50, height: 8)
                }
            }
            Image(systemName: "arrow.right").font(.title3.weight(.bold)).foregroundStyle(.secondary)
            // 캘린더 앱 아이콘처럼: 위에 요일, 가운데 큰 날짜, 아래 일정 막대
            VStack(spacing: 0) {
                Text(Calendar.app.shortWeekdaySymbols[5].uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.red)
                    .padding(.top, 8)
                Text(verbatim: "7")
                    .font(.system(size: 40, weight: .light))
                VStack(spacing: 3) {
                    Capsule().fill(AppTheme.Colors.bonus).frame(height: 6)
                    Capsule().fill(Color.blue.opacity(0.35)).frame(height: 6)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
            .frame(width: 96, height: 110)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        }
        .padding(16)
    }
}

// MARK: - 프로

/// 보너스 연차: 대체휴무 · 포상휴가, 남은 날과 만료일
private struct BonusLeaveArt: View {
    private let items: [(symbol: String, color: Color, left: Double, total: Double, month: Int, day: Int)] = [
        ("arrow.triangle.2.circlepath", .orange, 1, 2, 3, 31),
        ("star.fill", .pink, 2, 3, 6, 30),
        ("cross.case.fill", .teal, 0.5, 1, 12, 31),
    ]
    var body: some View {
        VStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { i in
                let item = items[i]
                ArtCard {
                    HStack(spacing: 10) {
                        Image(systemName: item.symbol).foregroundStyle(item.color).frame(width: 22)
                        VStack(alignment: .leading, spacing: 4) {
                            ProgressView(value: item.left, total: item.total).tint(item.color)
                            Label(dateRange(month: item.month, from: item.day, to: item.day), systemImage: "clock")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                        Text(verbatim: "+\(item.left.formatted())")
                            .font(.subheadline.weight(.bold)).foregroundStyle(item.color)
                    }
                }
            }
        }
        .padding(16)
    }
}

/// 종류별 연간 한도: 종류마다 쓴 만큼 차는 고리
private struct AllowanceArt: View {
    private let items: [(symbol: String, color: Color, used: Int, limit: Int)] = [
        ("cross.case.fill", .teal, 2, 5), ("figure.2.and.child.holdinghands", .pink, 3, 3), ("star.fill", .orange, 1, 4),
    ]
    var body: some View {
        HStack(spacing: 12) {
            ForEach(items.indices, id: \.self) { i in
                let item = items[i]
                ArtCard {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle().stroke(item.color.opacity(0.18), lineWidth: 7)
                            Circle().trim(from: 0, to: CGFloat(item.used) / CGFloat(item.limit))
                                .stroke(item.color, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            Image(systemName: item.symbol).foregroundStyle(item.color)
                        }
                        .frame(width: 54, height: 54)
                        Text(verbatim: "\(item.used)/\(item.limit)")
                            .font(.subheadline.weight(.bold)).monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
    }
}

/// 학교 달력 가져오기: 학사 일정 사진 → 달력에 방학
private struct SchoolImportArt: View {
    var body: some View {
        HStack(spacing: 12) {
            // 찍은 학사 일정표
            VStack(alignment: .leading, spacing: 5) {
                ForEach(0..<6, id: \.self) { i in
                    HStack(spacing: 4) {
                        Capsule().fill(Color.secondary.opacity(0.35)).frame(width: 14, height: 5)
                        Capsule().fill(i == 2 || i == 3 ? Color.indigo : Color.secondary.opacity(0.25))
                            .frame(width: CGFloat([38, 30, 44, 36, 28, 40][i]), height: 5)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.indigo, style: StrokeStyle(lineWidth: 2, dash: [5, 4])))
            .rotationEffect(.degrees(-4))
            Image(systemName: "arrow.right").font(.title3.weight(.bold)).foregroundStyle(.secondary)
            ArtCard {
                ArtMonth(title: monthName(7), startColumn: 4,
                         marked: Set(20...31), markColor: .indigo)
            }
        }
        .padding(16)
    }
}

/// 캘린더 자동 감지: 캘린더에 적은 휴가 일정 → 휴가 기록
private struct AutoDetectArt: View {
    var body: some View {
        VStack(spacing: 10) {
            ArtCard {
                HStack(spacing: 10) {
                    Capsule().fill(Color.blue).frame(width: 4, height: 28)
                    Image(systemName: "airplane").foregroundStyle(.blue)
                    Text(dateRange(month: 8, from: 10, to: 14)).font(.subheadline.weight(.semibold))
                    Spacer()
                }
            }
            Image(systemName: "arrow.down").font(.title3.weight(.bold)).foregroundStyle(.secondary)
            ArtCard {
                HStack(spacing: 10) {
                    Capsule().fill(AppTheme.Colors.bonus).frame(width: 4, height: 28)
                    Image(systemName: "briefcase.fill").foregroundStyle(AppTheme.Colors.bonus)
                    Text(dateRange(month: 8, from: 10, to: 14)).font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                }
            }
        }
        .padding(16)
    }
}

/// 함께 쉬기: 가족마다 쉬는 날, 모두 쉬는 날은 한 줄로 빛난다
private struct TogetherArt: View {
    /// 사람마다 쉬는 날(일주일 중)
    private let people: [(color: Color, off: Set<Int>)] = [
        (.blue, [0, 3, 4, 5, 6]), (.pink, [0, 1, 4, 5, 6]), (.green, [2, 4, 5, 6]),
    ]
    var body: some View {
        ArtCard {
            VStack(spacing: 8) {
                ForEach(people.indices, id: \.self) { p in
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2).foregroundStyle(people[p].color)
                        ForEach(0..<7, id: \.self) { d in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(people[p].off.contains(d) ? people[p].color.opacity(0.75) : Color.secondary.opacity(0.15))
                                .frame(height: 18)
                        }
                    }
                }
            }
            .overlay {
                // 모두 쉬는 날(4 · 5 · 6번째)을 한 틀로
                GeometryReader { g in
                    let avatar: CGFloat = 30, gap: CGFloat = 6
                    let cell = (g.size.width - avatar - gap * 7) / 7
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(AppTheme.Colors.bonus, lineWidth: 2.5)
                        .frame(width: cell * 3 + gap * 2 + 6, height: g.size.height + 8)
                        .offset(x: avatar + gap + (cell + gap) * 4 - 3, y: -4)
                }
            }
        }
        .padding(16)
    }
}

/// 가족 기념일: 달력에 하트, 그 앞뒤로 쉬는 날
private struct AnniversaryArt: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "birthday.cake.fill").foregroundStyle(.pink)
                Text(dateRange(month: 4, from: 16, to: 16)).font(.subheadline.weight(.bold))
                Image(systemName: "bell.badge.fill").foregroundStyle(.orange)
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Color(.systemBackground), in: Capsule())
            .shadow(color: .black.opacity(0.06), radius: 4, y: 1)
            ArtCard {
                ArtMonth(title: monthName(4), days: 30, startColumn: 4,
                         leave: [15], hearts: [16])
            }
        }
        .padding(16)
    }
}
