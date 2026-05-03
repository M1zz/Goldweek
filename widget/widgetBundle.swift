//
//  widgetBundle.swift
//  휴가캘린더 위젯
//

import WidgetKit
import SwiftUI

@main
struct LeaveWidgetBundle: WidgetBundle {
    var body: some Widget {
        DDayWidget()
        LeaveWidget()
        LeaveAccessoryWidget()
        BurnRateWidget()
    }
}
