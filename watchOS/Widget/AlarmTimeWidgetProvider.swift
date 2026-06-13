//
//  AlarmTimeWidgetProvider.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import WidgetKit

struct AlarmTimeWidgetProvider: TimelineProvider {
  
  private let placeholderInterval: TimeInterval = 3600

  func placeholder(in context: Context) -> AlarmEntry {
    AlarmEntry(
      date: Date(),
      alarmDate: Date().addingTimeInterval(placeholderInterval)
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (AlarmEntry) -> Void) {
    let entry = AlarmEntry(date: Date(), alarmDate: AlarmTimeWidgetDefaults.alarmDate)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let now = Date.now
    let currentEntry = AlarmEntry(date: now, alarmDate: AlarmTimeWidgetDefaults.alarmDate)

    var entries = [currentEntry]

    if let currentAlarmDate = AlarmTimeWidgetDefaults.alarmDate, currentAlarmDate > now {
      entries.append(AlarmEntry(date: currentAlarmDate, alarmDate: nil))
    }

    let timeline = Timeline(entries: entries, policy: .never)
    completion(timeline)
  }

}
