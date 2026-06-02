//
//  Persistence.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

enum PersistenceError: Error {

  case saveFailed
  case deleteDreamFailed
  case fetchSleepFailed
  case fetchLatestSleepFailed
  case fetchFinishedSleepsFailed
  case deleteSleepFailed
  case fetchTimeSessionFailed
  case fetchTimeSessionByAlarmIDFailed
  case fetchTimeHistoryFailed
  case fetchUserFailed
  case fetchFirstUserFailed
  case createUserFailed

}

extension PersistenceError: LocalizedError {

  var errorDescription: String? {
    switch self {
    case .saveFailed:
      return String(localized: "Your changes couldn't be saved.", comment: "Persistence error on save")
    case .deleteDreamFailed:
      return String(localized: "Couldn't delete the dream entry.", comment: "Persistence error when deleting a dream record")
    case .fetchSleepFailed:
      return String(localized: "Couldn't load this sleep session.", comment: "Persistence error when fetching a specific sleep session")
    case .fetchLatestSleepFailed:
      return String(localized: "Couldn't load your latest sleep session.", comment: "Persistence error when fetching the most recent sleep session")
    case .fetchFinishedSleepsFailed:
      return String(localized: "Couldn't load past sleep sessions.", comment: "Persistence error when fetching past sleep sessions")
    case .deleteSleepFailed:
      return String(localized: "Couldn't delete the sleep session.", comment: "Persistence error when deleting a sleep session")
    case .fetchTimeSessionFailed:
      return String(localized: "Couldn't load the active timer.", comment: "Persistence error when fetching the active timer session")
    case .fetchTimeSessionByAlarmIDFailed:
      return String(localized: "Couldn't load the timer for this alarm.", comment: "Persistence error when fetching the timer by alarm ID")
    case .fetchTimeHistoryFailed:
      return String(localized: "Couldn't load your timer history.", comment: "Persistence error when fetching timer history")
    case .fetchUserFailed:
      return String(localized: "Couldn't load your profile.", comment: "Persistence error when fetching a user profile")
    case .fetchFirstUserFailed:
      return String(localized: "Couldn't load your profiles.", comment: "Persistence error when fetching any user profile")
    case .createUserFailed:
      return String(localized: "Couldn't create the default profile.", comment: "Persistence error when creating the default user profile")
    }
  }

}

/// Shared `@ModelActor` that provides a single `modelContext` for all
/// domain-specific repository extensions.
///
/// Domain operations live in dedicated files:
/// - `Persistence+UserRepository`
/// - `Persistence+TimeRepository`
/// - `Persistence+SleepRepository`
/// - `Persistence+DreamRepository`
/// - `Persistence+SnapshotRepository`
actor Persistence: ModelActor {
  nonisolated let modelExecutor: any ModelExecutor
  nonisolated let modelContainer: ModelContainer
  var logger: (any LoggerProtocol)?

  init(
    modelContainer: ModelContainer,
    logger: (any LoggerProtocol)? = nil
  ) {
    let modelContext = ModelContext(modelContainer)
    self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
    self.modelContainer = modelContainer
    self.logger = logger
  }

  /// Saves pending model context changes and logs any failure.
  func save() {
    do {
      try modelContext.save()
    } catch {
      logger?.log(
        .error(PersistenceError.saveFailed.localizedDescription)
      )
    }
  }

  /// Saves pending model context changes, rolling back and rethrowing on failure.
  func trySave() throws {
    do {
      try modelContext.save()
    } catch {
      modelContext.rollback()
      throw error
    }
  }

}
