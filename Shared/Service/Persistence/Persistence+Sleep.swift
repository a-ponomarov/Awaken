//
//  Persistence+Sleep.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

// MARK: - SleepDateID

/// Identifies a sleep session together with its scheduled wake date.
struct SleepDateID {

  /// The sleep session identifier.
  let id: Date

  /// The scheduled wake date associated with the session, when available.
  let scheduledDate: Date?

}

extension Persistence {

  /// Creates a new sleep session scheduled to end at the provided date.
  func createSleep(endDate: Date) {
    let sleep = Sleep(scheduledDate: endDate)
    sleep.user = user
    modelContext.insert(sleep)
    save()
    #if os(watchOS)
    AlarmTimeWidgetDefaults.setAlarmDate(endDate)
    #endif
  }

  /// Finalizes the current session and marks it expired, or deletes it
  /// when empty.
  func finishSession() {
    guard let sleep = fetchLatestSleep() else { return }
    #if os(watchOS)
    AlarmTimeWidgetDefaults.setAlarmDate(nil)
    #endif
    let snapshots = sleep.snapshots ?? []
    if snapshots.isEmpty {
      deleteSleep(id: sleep.id)
    } else {
      sleep.expirationDate = .now
      save()
    }
  }

  /// Deletes the latest session without marking it completed.
  func deleteSession() {
    guard let id = fetchLatestSleep()?.id else { return }
    #if os(watchOS)
    AlarmTimeWidgetDefaults.setAlarmDate(nil)
    #endif
    deleteSleep(id: id)
  }

  /// Fetches a sleep session by identifier.
  func fetchSleep(id: Date) -> Sleep? {
    do {
      let descriptor = FetchDescriptor<Sleep>(
        predicate: #Predicate {
          $0.id == id
        }
      )
      return try modelContext.fetch(descriptor).first
    } catch {
      logger?.log(
        .error(PersistenceError.fetchSleepFailed.localizedDescription)
      )
      return nil
    }
  }

  /// Fetches the most recently created sleep session.
  func fetchLatestSleep() -> Sleep? {
    var descriptor = FetchDescriptor<Sleep>(
      sortBy: [SortDescriptor(\.id, order: .reverse)]
    )
    descriptor.fetchLimit = 1
    do {
      return try modelContext.fetch(descriptor).first
    } catch {
      logger?.log(
        .error(PersistenceError.fetchLatestSleepFailed.localizedDescription)
      )
      return nil
    }
  }

  /// Fetches the latest sleep identifier and scheduled date.
  func latestSleepID() -> SleepDateID? {
    guard let sleep = fetchLatestSleep() else { return nil }
    return SleepDateID(id: sleep.id, scheduledDate: sleep.scheduledDate)
  }

  /// Returns finished sleep IDs not yet used for personalization.
  func finishedSleepIDsNotUsedForPersonalization() -> [Date] {
    let descriptor = FetchDescriptor<Sleep>(
      predicate: #Predicate<Sleep> {
        $0.expirationDate != nil &&
        $0.usedForPersonalization == false &&
        $0.skipPersonalization == false
      },
      sortBy: [SortDescriptor(\.id, order: .forward)]
    )
    do {
      let sleeps = try modelContext.fetch(descriptor)
      return sleeps.map { $0.id }
    } catch {
      logger?.log(
        .error(
          PersistenceError.fetchFinishedSleepsFailed.localizedDescription
        )
      )
      return []
    }
  }

  /// Marks a sleep session as used for personalization.
  func markSleepUsedForPersonalization(id: Date) {
    guard let sleep = fetchSleep(id: id) else { return }
    sleep.usedForPersonalization = true
    save()
  }

  /// Marks a sleep session as unsuitable for personalization retries.
  func markSleepSkippedForPersonalization(id: Date) {
    guard let sleep = fetchSleep(id: id) else { return }
    sleep.skipPersonalization = true
    save()
  }

  /// Deletes a sleep session by identifier.
  func deleteSleep(id: Date) {
    do {
      try modelContext.delete(
        model: Sleep.self,
        where: #Predicate {
          $0.id == id
        }
      )
      save()
      #if os(watchOS)
      AlarmTimeWidgetDefaults.setAlarmDate(nil)
      #endif
    } catch {
      logger?.log(
        .error(PersistenceError.deleteSleepFailed.localizedDescription)
      )
    }
  }

}
