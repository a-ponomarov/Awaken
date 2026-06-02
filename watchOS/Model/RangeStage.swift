//
//  RangeStage.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

nonisolated
struct RangeStage {

  let startDate: Date
  let endDate: Date
  let stage: Stage

  func contains(_ date: Date) -> Bool {
    date >= startDate && date < endDate
  }

}
