//
//  Sleep.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

@Model
final class Sleep {

  var id = Date()

  @Relationship(deleteRule: .cascade, inverse: \Snapshot.sleep)
  var snapshots: [Snapshot]? = []

  @Relationship var user: User?

  var scheduledDate: Date?
  var expirationDate: Date?
  var usedForPersonalization = false
  var skipPersonalization = false

  init(scheduledDate: Date) {
    self.scheduledDate = scheduledDate
  }

}
