//
//  CountdownLiveActivityView.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AlarmKit
import SwiftUI

struct CountdownLiveActivityView: View {

  private enum Constants {

    static let horizontalPadding: CGFloat = 22
    static let verticalPadding: CGFloat = 14

  }

  let attributes: AlarmAttributes<CountdownLiveActivityMetadata>
  let state: AlarmPresentationState

  var body: some View {
    VStack {
      if let taskName {
        CountdownTaskText(taskName: taskName)
      }

      CountdownBottomView(
        attributes: attributes,
        state: state
      )
    }
    .padding(.horizontal, Constants.horizontalPadding)
    .padding(.vertical, Constants.verticalPadding)
  }

  private var taskName: String? {
    guard let taskName = attributes.metadata?.taskName?.trimmingCharacters(in: .whitespacesAndNewlines),
          !taskName.isEmpty
    else {
      return nil
    }

    return taskName
  }

}

struct CountdownBottomView: View {

  let attributes: AlarmAttributes<CountdownLiveActivityMetadata>
  let state: AlarmPresentationState
  let layout: LiveActivityLayout
  let buttonSizeStyle: CountdownLiveActivityButtonSizeStyle

  init(
    attributes: AlarmAttributes<CountdownLiveActivityMetadata>,
    state: AlarmPresentationState,
    layout: LiveActivityLayout = .lockScreenExpanded,
    buttonSizeStyle: CountdownLiveActivityButtonSizeStyle = .regular
  ) {
    self.attributes = attributes
    self.state = state
    self.layout = layout
    self.buttonSizeStyle = buttonSizeStyle
  }

  var body: some View {
    HStack {
      CountdownButtons(
        attributes: attributes,
        state: state,
        buttonSizeStyle: buttonSizeStyle
      )

      Spacer()

      CountdownLiveActivityText(state: state, layout: layout)
    }
  }

}

struct CountdownButtons: View {

  let attributes: AlarmAttributes<CountdownLiveActivityMetadata>
  let state: AlarmPresentationState
  let buttonSizeStyle: CountdownLiveActivityButtonSizeStyle

  var body: some View {
    HStack {
      switch state.mode {
      case .countdown:
        CountdownLiveActivityButton(
          configuration: attributes.presentation.countdown?.pauseButton,
          intent: PauseIntent(alarmID: state.alarmID.uuidString),
          tint: AppColors.accent,
          sizeStyle: buttonSizeStyle
        )

        stopButton
      case .paused:
        CountdownLiveActivityButton(
          configuration: attributes.presentation.paused?.resumeButton,
          intent: ResumeIntent(alarmID: state.alarmID.uuidString),
          tint: AppColors.accent,
          sizeStyle: buttonSizeStyle
        )

        stopButton
      default:
        stopButton
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var stopButton: some View {
    CountdownLiveActivityButton(
      configuration: AlarmButton(
        text: "Stop",
        textColor: .white,
        systemImageName: "stop.fill"
      ),
      intent: StopIntent(alarmID: state.alarmID.uuidString),
      tint: AppColors.accent,
      sizeStyle: buttonSizeStyle
    )
  }

}

struct CountdownTaskText: View {

  let taskName: String

  var body: some View {
    Text(taskName)
      .font(AppFont.bodyMedium)
      .foregroundStyle(AppColors.primary)
      .frame(maxWidth: .infinity, alignment: .leading)
  }

}
