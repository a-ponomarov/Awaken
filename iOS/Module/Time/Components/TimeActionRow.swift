//
//  TimeActionRow.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimeActionRow: View {

  private enum Constants {

    static let controlSize: CGFloat = 52
    static let ctaHeight: CGFloat = 52

  }

  let canStop: Bool
  let status: TimeStatus
  let actionSymbolName: String
  let primaryActionTitle: String
  let onStop: () -> Void
  let onToggle: () -> Void

  var body: some View {
    HStack(spacing: AppLayout.spacing * 3) {
      if canStop {
        Button(action: onStop) {
          Image(systemName: "stop.fill")
            .font(AppFont.button)
            .frame(
              width: Constants.controlSize,
              height: Constants.controlSize
            )
            .background(
              Circle()
                .fill(AppColors.surface)
            )
            .overlay {
              Circle()
                .stroke(AppColors.tint, lineWidth: AppLayout.stroke)
            }
        }
        .buttonStyle(.plain)
      }

      Button(action: onToggle) {
        Image(systemName: actionSymbolName)
          .font(AppFont.button)
          .frame(maxWidth: .infinity)
          .frame(height: Constants.ctaHeight)
          .foregroundStyle(AppColors.blue)
          .background(
            Capsule()
              .fill(Color.white.opacity(0.94))
          )
      }
      .buttonStyle(.plain)
      .accessibilityLabel(primaryActionTitle)
    }
  }

}
