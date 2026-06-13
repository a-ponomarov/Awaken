//
//  User.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

@Model
final class User {

  var id = UUID()
  var birthday = Date()

  @Relationship(deleteRule: .cascade, inverse: \Sleep.user)
  var sleeps: [Sleep]? = []

  @Relationship(deleteRule: .cascade, inverse: \Dream.user)
  var dreams: [Dream]? = []

  @Relationship(deleteRule: .cascade, inverse: \Time.user)
  var times: [Time]? = []

  init() {

  }

}
