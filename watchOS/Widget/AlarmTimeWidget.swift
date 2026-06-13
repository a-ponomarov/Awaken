//
//  AlarmTimeWidget.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI
import WidgetKit

struct AlarmTimeWidget: Widget {

  private let kind = "AlarmComplication"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: AlarmTimeWidgetProvider()) { entry in
      AlarmComplication(date: entry.alarmDate)
        .containerBackground(.clear, for: .widget)
    }
    .supportedFamilies([.accessoryCircular])
  }

}


