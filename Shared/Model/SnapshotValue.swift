//
//  SnapshotValue.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

struct SnapshotValue: Identifiable {

  let id: UUID
  let timestamp: Date
  let features: [Double]
  let stage: Stage?

  nonisolated init(snapshot: Snapshot) {
    self.id = snapshot.id
    self.timestamp = snapshot.timestamp
    self.features = snapshot.features
    self.stage = snapshot.stage
  }

  init(
    id: UUID = UUID(),
    timestamp: Date,
    features: [Double] = [],
    stage: Stage?
  ) {
    self.id = id
    self.timestamp = timestamp
    self.features = features
    self.stage = stage
  }

}
