//
//  DateFormatter+DateTime.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

extension DateFormatter {

  static nonisolated let shortTime: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
  }()

  static nonisolated let mediumTime: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    return formatter
  }()

  static nonisolated let hour: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.setLocalizedDateFormatFromTemplate("j")
    return formatter
  }()

}

nonisolated
extension DateFormatter {

  static var is12HourFormat: Bool {
    dateFormat(fromTemplate: "j", options: 0, locale: .current)?.contains("a") ?? false
  }

}

extension NumberFormatter {

  static let decimal: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
  }()

}

extension Int64 {

  var decimal: String {
    NumberFormatter.decimal.string(from: NSNumber(value: self)) ?? description
  }

}
