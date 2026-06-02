//
//  AlarmIdentifiers.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

nonisolated
enum AlarmIdentifiers {

  static let wake: UUID = {
    guard let id = UUID(uuidString: "00000000-0000-0000-0000-000000000008") else {
      preconditionFailure("Invalid UUID string for wake identifier")
    }
    return id
  }()

  static let time: UUID = {
    guard let id = UUID(uuidString: "00000000-0000-0000-0000-000000000009") else {
      preconditionFailure("Invalid UUID string for time identifier")
    }
    return id
  }()

}
