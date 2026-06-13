//
//  Logger.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

// MARK: - LoggerProtocol

/// Defines the logging interface used by persistence services.
protocol LoggerProtocol: Actor {

  /// Records a log event asynchronously.
  /// - Parameter event: The event to record.
  nonisolated func log(_ event: LogEvent)

}

// MARK: - Logger

/// Persists diagnostic log events in the dedicated log store.
actor Logger: ModelActor, LoggerProtocol {

  nonisolated let modelExecutor: any ModelExecutor
  nonisolated let modelContainer: ModelContainer
  private static let cleanupIntervalSeconds: TimeInterval = 7 * 24 * 3600
  private let maxLogCount = 10_000
  private static let lastCleanupDateKey = "lastLogCleanupDate"
  init(modelContainer: ModelContainer) {
    let modelContext = ModelContext(modelContainer)
    self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
    self.modelContainer = modelContainer
  }

  /// Records a log event without blocking the caller.
  /// - Parameter event: The event to record.
  nonisolated func log(_ event: LogEvent) {
    let now = Date.now
    Task.detached(priority: .background) { [weak self] in
      await self?.log(date: now, event: event)
    }
  }

  private func log(date: Date, event: LogEvent) async {
    let log = Log(
      date: date,
      event: event
    )
    #if DEBUG
    print(log.formatted)
    #endif
    modelContext.insert(log)
    try? modelContext.save()
    await cleanupIfNeeded()
  }

  private func cleanupIfNeeded() async {
    let cleanupDate = UserDefaults.standard.object(
      forKey: Self.lastCleanupDateKey
    ) as? Date ?? .distantPast
    guard
      Date.now.timeIntervalSince(cleanupDate) > Self.cleanupIntervalSeconds
    else {
      return
    }

    cleanup()
    UserDefaults.standard.set(Date.now, forKey: Self.lastCleanupDateKey)
  }

  private func cleanup() {
    do {
      let logCount = try modelContext.fetchCount(FetchDescriptor<Log>())
      
      guard logCount > maxLogCount else { return }

      var overflowDescriptor = FetchDescriptor<Log>(
        sortBy: [SortDescriptor(\.date, order: .reverse)]
      )
      overflowDescriptor.fetchOffset = maxLogCount

      let expiredLogs = try modelContext.fetch(overflowDescriptor)
      
      for log in expiredLogs {
        modelContext.delete(log)
      }

      if modelContext.hasChanges {
        try modelContext.save()
      }
    } catch {
      print(error.localizedDescription)
    }
  }

}
