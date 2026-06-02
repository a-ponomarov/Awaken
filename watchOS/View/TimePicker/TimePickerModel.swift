//
//  TimePickerModel.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class TimePickerModel {

  let is12HourFormat = DateFormatter.is12HourFormat

  var time: Date
  var hour: Int
  var minute: Int
  var isAM: Bool

  init(time: Date) {
    self.time = time

    let hour = Calendar.current.component(.hour, from: time)
    self.isAM = hour < 12
    self.hour = is12HourFormat ? Self.convertTo12Hour(hour) : hour
    self.minute = Calendar.current.component(.minute, from: time)
  }

  func confirmSelection() -> Date {
    let resolvedHour = is12HourFormat ? Self.convertTo24Hour(hour, isAM: isAM) : hour
    let calendar = Calendar.current
    time = calendar.date(
      bySettingHour: resolvedHour,
      minute: minute,
      second: 0,
      of: Date.now
    ) ?? .now
    return time
  }

  private static func convertTo12Hour(_ h: Int) -> Int {
    let hour = h % 12
    return hour == 0 ? 12 : hour
  }

  private static func convertTo24Hour(_ hour: Int, isAM: Bool) -> Int {
    if isAM {
      return hour == 12 ? 0 : hour
    } else {
      return hour == 12 ? 12 : hour + 12
    }
  }

}
