//
//  TimePresetButton.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimePresetButton: View {

  private enum Constants {

    static let presetHeight: CGFloat = 36

  }

  let title: String?
  let systemImageName: String?
  let isSelected: Bool
  let isEnabled: Bool
  let action: () -> Void

  init(
    title: String,
    isSelected: Bool,
    isEnabled: Bool,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.systemImageName = nil
    self.isSelected = isSelected
    self.isEnabled = isEnabled
    self.action = action
  }

  init(
    systemImageName: String,
    isSelected: Bool,
    isEnabled: Bool,
    action: @escaping () -> Void
  ) {
    self.title = nil
    self.systemImageName = systemImageName
    self.isSelected = isSelected
    self.isEnabled = isEnabled
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      Group {
        if let title {
          Text(title)
        } else if let systemImageName {
          Image(systemName: systemImageName)
        }
      }
      .font(AppFont.buttonSmall)
      .foregroundStyle(isSelected ? AppColors.background : AppColors.primary)
      .frame(maxWidth: .infinity)
      .frame(height: Constants.presetHeight)
      .background(
        Capsule()
          .fill(isSelected ? Color.white.opacity(0.92) : AppColors.surface)
      )
      .overlay {
        Capsule()
          .stroke(
            isSelected ? Color.clear : AppColors.accent,
            lineWidth: AppLayout.stroke
          )
      }
    }
    .buttonStyle(.plain)
    .disabled(!isEnabled)
  }

}
