//
//  SheetDestination.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

enum SheetDestination: Identifiable, Hashable {

  case alarmTimePicker(initialTime: Date)
  case wakeStagePicker

  var id: SheetDestination {
    self
  }

}
