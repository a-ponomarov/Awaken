//
//  CountdownLiveActivityText.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AlarmKit
import SwiftUI

struct CountdownLiveActivityText: View {

  private enum Constants {

    static let lockScreenExpandedFontSize = 34.0
    static let dynamicIslandExpandedFontSize = 26.0
    static let compactFontSize = 14.0
    static let lockScreenExpandedMinimumScaleFactor = 0.61
    static let dynamicIslandExpandedMinimumScaleFactor = 0.58
    static let compactMinimumScaleFactor = 0.58
    static let compactMaxWidth = 46.0
    static let secondsPerHour = 60 * 60

  }

  let state: AlarmPresentationState
  let layout: LiveActivityLayout

  init(state: AlarmPresentationState, layout: LiveActivityLayout = .lockScreenExpanded) {
    self.state = state
    self.layout = layout
  }

  var body: some View {
    Group {
      switch state.mode {
      case .countdown(let countdown):
        Text(timerInterval: Date.now ... countdown.fireDate, countsDown: true)
      case .paused(let paused):
        let remaining = Duration.seconds(
          paused.totalCountdownDuration - paused.previouslyElapsedDuration
        )
        let pattern: Duration.TimeFormatStyle.Pattern =
          remaining > .seconds(Constants.secondsPerHour)
          ? .hourMinuteSecond
          : .minuteSecond
        Text(remaining.formatted(.time(pattern: pattern)))
      case .alert:
        EmptyView()
      default:
        EmptyView()
      }
    }
    .font(.bold(size: fontSize))
    .monospacedDigit()
    .foregroundStyle(.white)
    .lineLimit(1)
    .minimumScaleFactor(minimumScaleFactor)
    .frame(maxWidth: maxWidth, alignment: .leading)
  }

  private var fontSize: Double {
    switch layout {
    case .lockScreenExpanded:
      Constants.lockScreenExpandedFontSize
    case .dynamicIslandExpanded:
      Constants.dynamicIslandExpandedFontSize
    case .compact:
      Constants.compactFontSize
    }
  }

  private var minimumScaleFactor: Double {
    switch layout {
    case .lockScreenExpanded:
      Constants.lockScreenExpandedMinimumScaleFactor
    case .dynamicIslandExpanded:
      Constants.dynamicIslandExpandedMinimumScaleFactor
    case .compact:
      Constants.compactMinimumScaleFactor
    }
  }

  private var maxWidth: CGFloat {
    switch layout {
    case .lockScreenExpanded, .dynamicIslandExpanded:
      .infinity
    case .compact:
      Constants.compactMaxWidth
    }
  }

}
