//
//  CountdownLiveActivityProgressView.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AlarmKit
import SwiftUI

struct CountdownLiveActivityProgressView: View {

  let mode: AlarmPresentationState.Mode
  let tint: Color

  var body: some View {
    Group {
      let hourglass = Image(systemName: "hourglass")
      switch mode {
      case .countdown(let countdown):
        ProgressView(
          timerInterval: Date.now ... countdown.fireDate,
          countsDown: true,
          label: { EmptyView() },
          currentValueLabel: {
            hourglass
          }
        )
      case .paused(let paused):
        let remaining = paused.totalCountdownDuration - paused.previouslyElapsedDuration
        ProgressView(
          value: remaining,
          total: paused.totalCountdownDuration,
          label: { EmptyView() },
          currentValueLabel: {
            hourglass
          }
        )
      default:
        Image(systemName: "timer")
          .font(.system(size: 14, weight: .semibold))
      }
    }
    .progressViewStyle(.circular)
    .foregroundStyle(tint)
    .tint(tint)
  }

}
