//
//  Snapshot.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

@Model
final class Snapshot {

  var id = UUID()

  @Relationship var sleep: Sleep?

  var timestamp = Date()

  var features: [Double] = []

  var stageRaw: String?

  var stage: Stage? {
    get { Stage(rawValue: stageRaw ?? "") }
    set { stageRaw = newValue?.rawValue }
  }

  init(
    id: UUID = UUID(),
    sleep: Sleep,
    timestamp: Date,
    features: [Double],
    stageRaw: String
  ) {
    self.id = id
    self.sleep = sleep
    self.timestamp = timestamp
    self.features = features
    self.stageRaw = stageRaw
  }

}
