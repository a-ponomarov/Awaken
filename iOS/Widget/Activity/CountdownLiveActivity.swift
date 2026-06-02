//
//  CountdownLiveActivity.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import ActivityKit
import AlarmKit
import SwiftUI
import WidgetKit

enum LiveActivityLayout {

  case lockScreenExpanded
  case dynamicIslandExpanded
  case compact

}

struct CountdownLiveActivity: Widget {

  var body: some WidgetConfiguration {
    ActivityConfiguration(for: AlarmAttributes<CountdownLiveActivityMetadata>.self) { context in
      CountdownLiveActivityView(attributes: context.attributes, state: context.state)
        .activityBackgroundTint(.black)
        .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.center) {
          CountdownDynamicIslandTaskView(taskName: context.attributes.metadata?.taskName)
        }
        DynamicIslandExpandedRegion(.bottom) {
          CountdownDynamicIslandBottomView(
            attributes: context.attributes,
            state: context.state
          )
        }
      } compactLeading: {
        CountdownLiveActivityProgressView(
          mode: context.state.mode,
          tint: context.attributes.tintColor
        )
      } compactTrailing: {
        CountdownLiveActivityText(state: context.state, layout: .compact)
          .foregroundStyle(.white)
      } minimal: {
        CountdownLiveActivityProgressView(
          mode: context.state.mode,
          tint: context.attributes.tintColor
        )
      }
      .keylineTint(context.attributes.tintColor)
    }
  }

}

private struct CountdownDynamicIslandBottomView: View {

  private enum Constants {

    static let horizontalPadding: CGFloat = 12
    static let topPadding: CGFloat = 6
    static let bottomPadding: CGFloat = 2

  }

  let attributes: AlarmAttributes<CountdownLiveActivityMetadata>
  let state: AlarmPresentationState

  var body: some View {
    CountdownBottomView(
      attributes: attributes,
      state: state,
      layout: .dynamicIslandExpanded,
      buttonSizeStyle: .compact
    )
      .padding(.horizontal, Constants.horizontalPadding)
      .padding(.top, Constants.topPadding)
      .padding(.bottom, Constants.bottomPadding)
  }

}

private struct CountdownDynamicIslandTaskView: View {

  private enum Constants {

    static let topPadding: CGFloat = 0
    static let horizontalPadding: CGFloat = 16
    static let bottomPadding: CGFloat = 8

  }

  let taskName: String?

  var body: some View {
    if let taskName {
      CountdownTaskText(taskName: taskName)
        .padding(.top, Constants.topPadding)
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.bottom, Constants.bottomPadding)
    }
  }

}
