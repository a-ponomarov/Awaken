//
//  Persistence+Snapshot.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

extension Persistence {

  /// Returns persisted snapshots for a specific sleep session.
  func snapshots(forSleepID sleepID: Date) -> [SnapshotValue] {
    fetchSleep(id: sleepID)?.snapshots?.map {
      SnapshotValue(snapshot: $0)
    } ?? []
  }

  /// Appends a new snapshot to the current sleep session.
  func addSnapshot(stage: String, features: [Double]) {
    guard let sleep = fetchLatestSleep() else { return }

    let snapshot = Snapshot(
      sleep: sleep,
      timestamp: .now,
      features: features,
      stageRaw: stage
    )

    modelContext.insert(snapshot)
    save()
  }

}
