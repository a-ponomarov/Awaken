//
//  Stage.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import HealthKit
import SwiftUI

enum Stage: String, CaseIterable {

  case awake = "AWAKE"
  case rem = "REM"
  case core = "CORE"
  case deep = "DEEP"

  nonisolated
  init?(sleepAnalysisRaw: Int) {
    switch HKCategoryValueSleepAnalysis(rawValue: sleepAnalysisRaw) {
    case .awake, .inBed:
      self = .awake
    case .asleepCore:
      self = .core
    case .asleepDeep:
      self = .deep
    case .asleepREM:
      self = .rem
    default:
      return nil
    }
  }

}
