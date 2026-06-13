//
//  CountdownLiveActivityButton.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AlarmKit
import AppIntents
import SwiftUI

enum CountdownLiveActivityButtonSizeStyle {

  case regular
  case compact

}

struct CountdownLiveActivityButton<IntentType>: View where IntentType: AppIntent {

  let configuration: AlarmButton
  let intent: IntentType
  let tint: Color
  let sizeStyle: CountdownLiveActivityButtonSizeStyle

  init?(
    configuration: AlarmButton?,
    intent: IntentType,
    tint: Color,
    sizeStyle: CountdownLiveActivityButtonSizeStyle = .regular
  ) {
    guard let configuration else {
      return nil
    }

    self.configuration = configuration
    self.intent = intent
    self.tint = tint
    self.sizeStyle = sizeStyle
  }

  var body: some View {
    Button(intent: intent) {
      Image(systemName: configuration.systemImageName)
        .font(.system(size: iconSize, weight: .semibold))
        .frame(width: buttonSize, height: buttonSize)
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.circle)
    .controlSize(.small)
    .tint(tint)
    .accessibilityLabel(Text(configuration.text))
  }

  private var buttonSize: Double {
    switch sizeStyle {
    case .regular:
      30.0
    case .compact:
      26.0
    }
  }

  private var iconSize: Double {
    switch sizeStyle {
    case .regular:
      14.0
    case .compact:
      12.0
    }
  }

}
