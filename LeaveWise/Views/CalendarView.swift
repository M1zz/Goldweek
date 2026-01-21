//
//  CalendarView.swift
//  LeaveWise
//
//  캘린더 뷰
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Bindable var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LeaveRecord.startDate) private var leaveRecords: [LeaveRecord]

    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var recordToEdit: LeaveRecord?
    @State private var showingDeleteAlert = false
    @State private var recordToDelete: LeaveRecord?

    private let holidayService = HolidayService()
    private let calendar = Calendar.current
    
    var holidays: [Holiday] {
        let year = calendar.component(.year, from: currentMonth)
        return holidayService.getHolidays(for: year)
    }
    
    var upcomingLeaves: [LeaveRecord] {
        let today = calendar.startOfDay(for: Date())
        return leaveRecords
            .filter { $0.status != .cancelled && $0.endDate >= today }
            .sorted { $0.startDate < $1.startDate }
    }

    var pastLeaves: [LeaveRecord] {
        let today = calendar.startOfDay(for: Date())
        return leaveRecords
            .filter { $0.status != .cancelled && $0.endDate < today }
            .sorted { $0.startDate > $1.startDate }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 월 네비게이션
                    MonthNavigator(currentMonth: $currentMonth)

                    // 캘린더 그리드
                    CalendarGrid(
                        currentMonth: currentMonth,
                        selectedDate: $selectedDate,
                        holidays: holidays,
                        leaveRecords: leaveRecords
                    )

                    // 범례
                    LegendView()

                    // 선택된 날짜 정보
                    SelectedDateInfo(
                        date: selectedDate,
                        holidays: holidays,
                        leaveRecords: leaveRecords
                    )

                    // 나의 연차 일정
                    MyLeaveListView(
                        upcomingLeaves: upcomingLeaves,
                        pastLeaves: pastLeaves,
                        onEdit: { record in
                            recordToEdit = record
                        },
                        onDelete: { record in
                            recordToDelete = record
                            showingDeleteAlert = true
                        }
                    )
                }
                .padding()
            }
            .navigationTitle("캘린더")
            .sheet(item: $recordToEdit) { record in
                EditLeaveSheet(record: record, profile: profile) {
                    recordToEdit = nil
                }
            }
            .alert("휴가 삭제", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) { }
                Button("삭제", role: .destructive) {
                    if let record = recordToDelete {
                        deleteRecord(record)
                    }
                }
            } message: {
                Text("이 휴가 기록을 삭제하시겠습니까?\n연차가 복원됩니다.")
            }
        }
    }

    private func deleteRecord(_ record: LeaveRecord) {
        // 연차 복원
        if record.type.deductsFromAnnual {
            let days = record.type == .half ? 0.5 : (record.type == .quarter ? 0.25 : Double(record.daysCount))
            profile.usedLeave -= days
        }

        modelContext.delete(record)
        do {
            try modelContext.save()
            HapticFeedback.success()
        } catch {
            // 롤백
            if record.type.deductsFromAnnual {
                let days = record.type == .half ? 0.5 : (record.type == .quarter ? 0.25 : Double(record.daysCount))
                profile.usedLeave += days
            }
            HapticFeedback.error()
        }
    }

}

// MARK: - 월 네비게이터
struct MonthNavigator: View {
    @Binding var currentMonth: Date
    
    private let calendar = Calendar.current
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: currentMonth)
    }
    
    var body: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.title2.bold())
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal)
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

// MARK: - 캘린더 그리드
struct CalendarGrid: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    let holidays: [Holiday]
    let leaveRecords: [LeaveRecord]
    
    private let calendar = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        
        // 마지막 주 채우기
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 요일 헤더
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption.bold())
                        .foregroundStyle(day == "일" ? .red : (day == "토" ? .blue : .primary))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 날짜 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isHoliday: isHoliday(date),
                            isLeave: isLeave(date),
                            isToday: calendar.isDateInToday(date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private func isHoliday(_ date: Date) -> Bool {
        holidays.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func isLeave(_ date: Date) -> Bool {
        leaveRecords.contains { record in
            date >= record.startDate && date <= record.endDate && record.status != .cancelled
        }
    }
}

// MARK: - 날짜 셀
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isHoliday: Bool
    let isLeave: Bool
    let isToday: Bool

    private let calendar = Calendar.current

    var dayNumber: Int {
        calendar.component(.day, from: date)
    }

    var isWeekend: Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }

    var textColor: Color {
        if isSelected {
            return .white
        } else if isHoliday || calendar.component(.weekday, from: date) == 1 {
            return AppTheme.Colors.holiday
        } else if calendar.component(.weekday, from: date) == 7 {
            return AppTheme.Colors.weekend
        }
        return .primary
    }

    var body: some View {
        ZStack {
            // 배경
            if isSelected {
                Circle()
                    .fill(AppTheme.Colors.brand)
            } else if isToday {
                Circle()
                    .stroke(AppTheme.Colors.brand, lineWidth: 2)
            }

            // 날짜 텍스트
            Text("\(dayNumber)")
                .font(.system(size: 14, weight: isToday ? .bold : .regular))
                .foregroundStyle(textColor)

            // 연차 표시
            if isLeave && !isSelected {
                Circle()
                    .fill(AppTheme.Colors.leave)
                    .frame(width: 6, height: 6)
                    .offset(y: 14)
            }

            // 공휴일 표시
            if isHoliday && !isSelected && !isLeave {
                Circle()
                    .fill(AppTheme.Colors.holiday)
                    .frame(width: 6, height: 6)
                    .offset(y: 14)
            }
        }
        .frame(height: 40)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(dayNumber)일\(isToday ? ", 오늘" : "")\(isHoliday ? ", 공휴일" : "")\(isLeave ? ", 연차" : "")\(isSelected ? ", 선택됨" : "")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - 범례
struct LegendView: View {
    var body: some View {
        HStack(spacing: 20) {
            LegendItem(color: AppTheme.Colors.holiday, text: "공휴일")
            LegendItem(color: AppTheme.Colors.leave, text: "연차")
            LegendItem(color: AppTheme.Colors.weekend, text: "주말")
        }
        .font(.caption)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("범례: 빨간색 공휴일, 초록색 연차, 파란색 주말")
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 선택된 날짜 정보
struct SelectedDateInfo: View {
    let date: Date
    let holidays: [Holiday]
    let leaveRecords: [LeaveRecord]
    
    private let calendar = Calendar.current
    
    var holidayOnDate: Holiday? {
        holidays.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    var leaveOnDate: LeaveRecord? {
        leaveRecords.first { record in
            date >= record.startDate && date <= record.endDate && record.status != .cancelled
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(date.formatted(date: .complete, time: .omitted))
                .font(.headline)
            
            if let holiday = holidayOnDate {
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundStyle(.red)
                    Text(holiday.name)
                    if holiday.isSubstitute {
                        Text("(대체공휴일)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if let leave = leaveOnDate {
                HStack {
                    Image(systemName: "calendar.badge.checkmark")
                        .foregroundStyle(.green)
                    Text("\(leave.type.rawValue)")
                    if !leave.note.isEmpty {
                        Text("- \(leave.note)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if holidayOnDate == nil && leaveOnDate == nil {
                Text("일정 없음")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 나의 연차 일정 리스트
struct MyLeaveListView: View {
    let upcomingLeaves: [LeaveRecord]
    let pastLeaves: [LeaveRecord]
    var onEdit: ((LeaveRecord) -> Void)?
    var onDelete: ((LeaveRecord) -> Void)?

    @State private var showPastLeaves = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Text("나의 연차 일정")
                    .font(.title3.bold())
                Spacer()
                Text("\(upcomingLeaves.count + pastLeaves.count)건")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if upcomingLeaves.isEmpty && pastLeaves.isEmpty {
                // 빈 상태
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("등록된 연차가 없습니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                // 안내 텍스트
                if onEdit != nil {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.tap")
                            .font(.caption2)
                        Text("탭하여 수정 · 스와이프하여 삭제")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }

                // 예정된 연차
                if !upcomingLeaves.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("예정된 일정")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.Colors.brand)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.Colors.brand.opacity(0.1))
                            .clipShape(Capsule())

                        ForEach(upcomingLeaves) { leave in
                            LeaveListRowInteractive(
                                leave: leave,
                                isUpcoming: true,
                                onEdit: onEdit,
                                onDelete: onDelete
                            )
                        }
                    }
                }

                // 지난 연차
                if !pastLeaves.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            withAnimation {
                                showPastLeaves.toggle()
                            }
                            HapticFeedback.selection()
                        } label: {
                            HStack {
                                Text("지난 일정")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                Image(systemName: showPastLeaves ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(pastLeaves.count)건")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        if showPastLeaves {
                            ForEach(pastLeaves.prefix(10)) { leave in
                                LeaveListRowInteractive(
                                    leave: leave,
                                    isUpcoming: false,
                                    onEdit: onEdit,
                                    onDelete: onDelete
                                )
                            }

                            if pastLeaves.count > 10 {
                                Text("외 \(pastLeaves.count - 10)건")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - 연차 리스트 행 (인터랙티브)
struct LeaveListRowInteractive: View {
    let leave: LeaveRecord
    let isUpcoming: Bool
    var onEdit: ((LeaveRecord) -> Void)?
    var onDelete: ((LeaveRecord) -> Void)?

    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .trailing) {
            // 스와이프 삭제 버튼 배경
            HStack(spacing: 0) {
                Spacer()

                if let onDelete = onDelete {
                    Button {
                        onDelete(leave)
                        withAnimation { offset = 0 }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "trash.fill")
                            Text("삭제")
                                .font(.caption2)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 70, height: 70)
                    }
                    .background(Color.red)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // 메인 콘텐츠
            LeaveListRow(leave: leave, isUpcoming: isUpcoming)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = max(value.translation.width, -70.0)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.3)) {
                                if value.translation.width < -30 {
                                    offset = -70.0
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
                .onTapGesture {
                    if offset != 0 {
                        withAnimation { offset = 0 }
                    } else {
                        onEdit?(leave)
                        HapticFeedback.selection()
                    }
                }
        }
    }
}

// MARK: - 연차 리스트 행
struct LeaveListRow: View {
    let leave: LeaveRecord
    let isUpcoming: Bool

    private let calendar = Calendar.current

    var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"

        if calendar.isDate(leave.startDate, inSameDayAs: leave.endDate) {
            return formatter.string(from: leave.startDate)
        } else {
            let endFormatter = DateFormatter()
            endFormatter.locale = Locale(identifier: "ko_KR")
            endFormatter.dateFormat = "M월 d일"
            return "\(formatter.string(from: leave.startDate)) ~ \(endFormatter.string(from: leave.endDate))"
        }
    }

    var daysCount: Int {
        let days = calendar.dateComponents([.day], from: leave.startDate, to: leave.endDate).day ?? 0
        return days + 1
    }

    var dDayText: String? {
        guard isUpcoming else { return nil }
        let today = calendar.startOfDay(for: Date())
        let startDay = calendar.startOfDay(for: leave.startDate)
        let days = calendar.dateComponents([.day], from: today, to: startDay).day ?? 0

        if days == 0 {
            return "오늘"
        } else if days > 0 {
            return "D-\(days)"
        }
        return nil
    }

    var typeColor: Color {
        leave.type.themeColor
    }

    var body: some View {
        HStack(spacing: 12) {
            // 휴가 유형 아이콘
            Image(systemName: leave.type.icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(typeColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(leave.type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if leave.type == .annual && daysCount > 1 {
                        Text("\(daysCount)일")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !leave.note.isEmpty {
                    Text(leave.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // D-Day 또는 상태
            if let dDay = dDayText {
                Text(dDay)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(dDay == "오늘" ? .white : AppTheme.Colors.brand)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(dDay == "오늘" ? AppTheme.Colors.brand : AppTheme.Colors.brand.opacity(0.1))
                    .clipShape(Capsule())
            } else if !isUpcoming {
                Text(leave.status.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isUpcoming ? 1 : 0.7)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(leave.type.rawValue), \(dateText)\(dDayText != nil ? ", \(dDayText!)" : "")")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, LeaveRecord.self, configurations: config)
    
    let profile = UserProfile(name: "홍길동", yearStartMonth: 1, totalAnnualLeave: 15, usedLeave: 5)
    container.mainContext.insert(profile)
    
    return CalendarView(profile: profile)
        .modelContainer(container)
}
