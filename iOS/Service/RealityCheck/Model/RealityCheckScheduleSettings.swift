//
//  RealityCheckScheduleSettings.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/16/2026.
//

import Foundation

struct RealityCheckScheduleSettings: Codable, Equatable {

  static let minimumDailyCount = 1
  static let maximumDailyCount = 8
  static let defaultDailyCount = 5
  static let minimumStartMinute = 0
  static let maximumEndMinute = 23 * 60 + 59
  static let defaultStartMinute = 9 * 60
  static let defaultEndMinute = 22 * 60

  var isEnabled: Bool
  var dailyCount: Int
  var startMinute: Int
  var endMinute: Int

  static let defaultValue = RealityCheckScheduleSettings(
    isEnabled: false,
    dailyCount: defaultDailyCount,
    startMinute: defaultStartMinute,
    endMinute: defaultEndMinute
  )

  var normalized: RealityCheckScheduleSettings {
    let normalizedDailyCount = min(max(dailyCount, Self.minimumDailyCount), Self.maximumDailyCount)
    let normalizedStartMinute = min(max(startMinute, Self.minimumStartMinute), Self.maximumEndMinute - 1)
    let normalizedEndMinute = min(max(endMinute, Self.minimumStartMinute + 1), Self.maximumEndMinute)

    if normalizedStartMinute < normalizedEndMinute {
      return RealityCheckScheduleSettings(
        isEnabled: isEnabled,
        dailyCount: normalizedDailyCount,
        startMinute: normalizedStartMinute,
        endMinute: normalizedEndMinute
      )
    }

    return RealityCheckScheduleSettings(
      isEnabled: isEnabled,
      dailyCount: normalizedDailyCount,
      startMinute: max(Self.minimumStartMinute, normalizedEndMinute - 60),
      endMinute: normalizedEndMinute
    )
  }

}
