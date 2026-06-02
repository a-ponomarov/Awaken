//
//  AlarmViewModel.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

@Observable
@MainActor
final class AlarmViewModel {

  private enum Constants {

    static let defaultFallAsleepBufferMinutes = Int(
      SleepCycleCalculator.defaultFallAsleepBuffer / 60
    )

  }

  private let alarmService: AlarmService
  private let defaults: KeyValueStore
  private let clockTask = AppTask()

  var currentTime = Date()
  var selectedTime: Date {
    didSet { defaults.set(selectedTime, forKey: StorageKey.lastSelectedTime) }
  }
  var fallAsleepBufferMinutes: Int {
    didSet {
      defaults.set(
        fallAsleepBufferMinutes,
        forKey: StorageKey.fallAsleepBufferMinutes
      )
    }
  }
  var showPermissionAlert = false

  var isAlarmActive: Bool { alarmService.isAlarmActive }

  var wakeUpTimes: [Date] {
    SleepCycleCalculator.wakeUpTimes(
      bedTime: currentTime,
      fallAsleepBuffer: TimeInterval(fallAsleepBufferMinutes * 60)
    )
  }

  init(alarmService: AlarmService, defaults: KeyValueStore = UserDefaults.standard) {
    self.alarmService = alarmService
    self.defaults = defaults
    let savedBufferMinutes = defaults.object(
      forKey: StorageKey.fallAsleepBufferMinutes
    ) as? Int
    let initialBufferMinutes = savedBufferMinutes ?? Constants.defaultFallAsleepBufferMinutes
    self.fallAsleepBufferMinutes = initialBufferMinutes

    if let saved = defaults.object(forKey: StorageKey.simpleAlarmDate) as? Date {
      self.selectedTime = saved.nextOccurrence()
    } else if let last = defaults.object(
      forKey: StorageKey.lastSelectedTime
    ) as? Date {
      self.selectedTime = last.nextOccurrence()
    } else {
      let initialCurrentTime = Date()
      self.currentTime = initialCurrentTime
      self.selectedTime = SleepCycleCalculator.wakeUpTimes(
        bedTime: initialCurrentTime,
        fallAsleepBuffer: TimeInterval(initialBufferMinutes * 60)
      ).last ?? initialCurrentTime
    }
  }

  /// Starts a one-second clock that updates `currentTime`.
  func startClock() {
    clockTask.schedule(every: .seconds(1)) { [weak self] in
      self?.currentTime = Date()
    }
  }

  func stopClock() {
    clockTask.currentTask = nil
  }

  func toggleAlarm() {
    if isAlarmActive {
      alarmService.cancel()
    } else {
      schedule(at: selectedTime)
    }
  }

  func schedule(at date: Date) {
    alarmService.schedule(at: date) { [weak self] in
      await MainActor.run {
        self?.showPermissionAlert = true
      }
    }
  }

  func selectWakeUpTime(_ date: Date) {
    selectedTime = date
    schedule(at: date)
  }

  func cyclesText(for date: Date) -> String {
    let diff = abs(date.timeIntervalSince(currentTime))
    let cycles = Int(round(diff / SleepCycleCalculator.cycleDuration))
    return "\(cycles) \(String.cycles)"
  }

}
