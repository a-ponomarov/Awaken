//
//  Date+DateTime.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

nonisolated
extension Date {

  func livedTotal(for component: Calendar.Component) -> Int64 {
    if component == .second {
      return Int64(Date().timeIntervalSince(self))
    }
    let calendar = Calendar.current
    let components = calendar.dateComponents([component], from: self, to: .now)
    return Int64(components.value(for: component) ?? 0)
  }

  var time: String {
    DateFormatter.shortTime.string(from: self)
  }

  var mediumTime: String {
    DateFormatter.mediumTime.string(from: self)
  }

  var hour: String {
    let formattedHour = DateFormatter.hour.string(from: self)
    return DateFormatter.is12HourFormat ? formattedHour : formattedHour + ":00"
  }

  var roundedToMinute: Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: self
    )
    return calendar.date(from: components) ?? self
  }

  var dayLabel: String {
    let calendar = Calendar.current
    if calendar.isDateInToday(self) {
      return .today
    } else if calendar.isDateInTomorrow(self) {
      return .tomorrow
    }
    return .init()
  }

  func nextOccurrence(from referenceDate: Date = .now, threshold: Int = 0) -> Date {

    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: self)
    let hour = components.hour ?? 0
    let minute = components.minute ?? 0

    var result = calendar.date(
      bySettingHour: hour,
      minute: minute,
      second: 0,
      of: referenceDate
    ) ?? referenceDate

    let thresholdDate = calendar.date(
      byAdding: .minute,
      value: threshold,
      to: referenceDate
    ) ?? referenceDate

    if result <= thresholdDate {
      result = calendar.date(byAdding: .day, value: 1, to: result) ?? result
    }

    return result
  }

}

extension Int {

  var time: String {
    Calendar.current.date(bySettingHour: self, minute: 0, second: 0, of: Date())?.hour ?? ""
  }

}
