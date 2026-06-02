//
//  Log.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

@Model
final class Log {

  var date = Date()
  var eventData: Data?

  var event: LogEvent? {
    get {
      guard let eventData else { return nil }
      return try? JSONDecoder().decode(LogEvent.self, from: eventData)
    }
    set {
      eventData = try? newValue.map { try JSONEncoder().encode($0) }
    }
  }

  var timestamp: String {
    date.formatted(date: .numeric, time: .standard)
  }

  var message: String {
    event?.text ?? ""
  }

  var formatted: String {
    return timestamp + ": " + message
  }

  init(date: Date = Date(), event: LogEvent? = nil) {
    self.date = date
    self.event = event
  }

}
