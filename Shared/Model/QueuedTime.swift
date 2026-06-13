//
//  QueuedTime.swift
//  Time
//
//  Created by Andrew Ponomarov on 6/12/2026.
//

import Foundation
import SwiftData

struct QueuedTimeRecord: Identifiable, Hashable, Sendable {

  let id: UUID
  let title: String
  let createdAt: Date

}

@Model
final class QueuedTime {

  var id = UUID()
  var title = ""
  var createdAt = Date()

  @Relationship var user: User?

  var entry: QueuedTimeRecord {
    QueuedTimeRecord(
      id: id,
      title: title,
      createdAt: createdAt
    )
  }

  init(
    id: UUID = UUID(),
    title: String = "",
    createdAt: Date = .now
  ) {
    self.id = id
    self.title = title
    self.createdAt = createdAt
  }

}
