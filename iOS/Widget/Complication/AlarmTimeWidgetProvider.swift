//
//  AlarmTimeWidgetProvider.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AlarmKit
import WidgetKit

struct AlarmTimeWidgetProvider: TimelineProvider {

  private enum Constants {

    static let placeholderInterval: TimeInterval = 3600

  }

  private let alarmManager: AlarmManager

  init(alarmManager: AlarmManager = .shared) {
    self.alarmManager = alarmManager
  }

  func placeholder(in context: Context) -> AlarmEntry {
    AlarmEntry(date: Date(), alarmDate: Date().addingTimeInterval(Constants.placeholderInterval))
  }

  func getSnapshot(in context: Context, completion: @escaping (AlarmEntry) -> Void) {
    let entry = AlarmEntry(date: Date(), alarmDate: activeAlarmDate)
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let now = Date.now
    let currentEntry = AlarmEntry(date: now, alarmDate: activeAlarmDate)

    var entries = [currentEntry]

    if let alarmDate = activeAlarmDate, alarmDate > now {
      entries.append(AlarmEntry(date: alarmDate, alarmDate: nil))
    }

    let timeline = Timeline(entries: entries, policy: .never)

    completion(timeline)
  }

  private var activeAlarmDate: Date? {
    let activeAlarm = (try? alarmManager.alarms)?
      .first { $0.id == AlarmIdentifiers.wake }
    if let schedule = activeAlarm?.schedule, case .fixed(let date) = schedule {
      return date
    }
    return nil
  }

}
