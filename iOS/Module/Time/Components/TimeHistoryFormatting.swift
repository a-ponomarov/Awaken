//
//  TimeHistoryFormatting.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

extension TimeRecord {

  var timeHistoryRangeText: String {
    guard let startedAt, let endedAt else { return "" }
    let startTimeText = startedAt.formatted(date: .omitted, time: .shortened)
    let endTimeText = endedAt.formatted(date: .omitted, time: .shortened)
    let calendar = Calendar.current

    if calendar.isDate(startedAt, equalTo: endedAt, toGranularity: .minute) {
      return startTimeText
    }

    if calendar.isDate(startedAt, inSameDayAs: endedAt) {
      return "\(startTimeText)-\(endTimeText)"
    }

    let startDateText = startedAt.formatted(date: .abbreviated, time: .omitted)
    let endDateText = endedAt.formatted(date: .abbreviated, time: .omitted)
    return "\(startDateText), \(startTimeText) - \(endDateText), \(endTimeText)"
  }

  var timeHistoryTitleText: String {
    let trimmedTaskName = taskName.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedTaskName.isEmpty ? String.addFocusLabel : trimmedTaskName
  }

  var hasTaskName: Bool {
    !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

}

extension TimeInterval {

  var timeHistoryDurationText: String {
    let totalSeconds = max(0, Int(rounded()))
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%d:%02d:%02d", hours, minutes, seconds)
  }

}
