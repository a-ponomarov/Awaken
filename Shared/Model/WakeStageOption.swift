//
//  WakeStageOption.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

enum WakeStageOption: String, CaseIterable {

  case dream
  case light

  var leadingText: String {
    switch self {
    case .dream:
      return .dreamStage
    case .light:
      return .lightStage
    }
  }

  var trailingText: String {
    switch self {
    case .dream:
      return .dreamStageHint
    case .light:
      return .lightStageHint
    }
  }

  var badgeText: String {
    switch self {
    case .dream:
      return .dreamStageBadge
    case .light:
      return .lightStageBadge
    }
  }

  func matches(_ stage: Stage) -> Bool {
    switch self {
    case .dream:
      return stage == .rem
    case .light:
      return stage == .awake || stage == .rem || stage == .core
    }
  }

}
