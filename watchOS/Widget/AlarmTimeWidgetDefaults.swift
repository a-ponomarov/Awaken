//
//  AlarmTimeWidgetDefaults.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import WidgetKit

nonisolated
struct AlarmTimeWidgetDefaults {

  private static let suiteName = "group.andrii.ponomarov.awakeflow"
  private static let alarmDateKey = "widgetAlarmDate"

  private static var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: suiteName)
  }

  static var alarmDate: Date? {
    sharedDefaults?.value(forKey: alarmDateKey) as? Date
  }

  static func setAlarmDate(_ date: Date?) {
    if let date {
      sharedDefaults?.set(date, forKey: alarmDateKey)
    } else {
      sharedDefaults?.removeObject(forKey: alarmDateKey)
    }
    WidgetCenter.shared.reloadAllTimelines()
  }

}
