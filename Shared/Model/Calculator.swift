//
//  Calculator.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

final class SleepCycleCalculator {

  static let cycleDuration: TimeInterval = 90 * 60
  static let defaultFallAsleepBuffer: TimeInterval = 15 * 60
  static let numberOfSleepCycles = 3...6

  static func sleepTime(
    cycle: Int,
    fallAsleepBuffer: TimeInterval = defaultFallAsleepBuffer
  ) -> Double {
    TimeInterval(cycle) * cycleDuration + fallAsleepBuffer
  }

  static func wakeUpTimes(
    bedTime: Date,
    fallAsleepBuffer: TimeInterval = defaultFallAsleepBuffer
  ) -> [Date] {
    let roundedBedTime = bedTime.roundedToMinute
    return numberOfSleepCycles.map {
      roundedBedTime + sleepTime(cycle: $0, fallAsleepBuffer: fallAsleepBuffer)
    }
  }

}
