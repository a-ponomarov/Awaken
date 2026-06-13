//
//  DurationSliderSheet.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct DurationSliderSheet: View {

  let minimumMinutes: Int
  let maximumMinutes: Int
  @Binding var selectedMinutes: Int
  let actionTitle: String
  let onCancel: () -> Void
  let onDone: () -> Void

  init(
    minimumMinutes: Int,
    maximumMinutes: Int,
    selectedMinutes: Binding<Int>,
    actionTitle: String = String.done,
    onCancel: @escaping () -> Void,
    onDone: @escaping () -> Void
  ) {
    self.minimumMinutes = minimumMinutes
    self.maximumMinutes = maximumMinutes
    self._selectedMinutes = selectedMinutes
    self.actionTitle = actionTitle
    self.onCancel = onCancel
    self.onDone = onDone
  }

  var body: some View {
    NavigationStack {
      VStack {

        Text(String.minutesShort(selectedMinutes))
          .font(.regular(size: 32))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)

        Slider(
          value: Binding(
            get: { Double(selectedMinutes) },
            set: { selectedMinutes = Int($0.rounded()) }
          ),
          in: Double(minimumMinutes) ... Double(maximumMinutes),
          step: 1
        )
        .tint(AppColors.primary)

        HStack {
          Text(String.minutesShort(minimumMinutes))
            .font(.regular(size: 13))
            .foregroundStyle(.white)

          Spacer()

          Stepper(
            value: $selectedMinutes,
            in: minimumMinutes ... maximumMinutes,
            step: 1
          ) { }
            .tint(AppColors.primary)
          .labelsHidden()
          .padding(.top)

          Spacer()

          Text(String.minutesShort(maximumMinutes))
            .font(.regular(size: 13))
            .foregroundStyle(.white)
        }
      }
      .padding(.horizontal, AppLayout.cardPadding)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(String.cancel, action: onCancel).tint(.white)
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button(actionTitle, action: onDone).tint(.white)
        }
      }
    }
    .background(AppColors.background.ignoresSafeArea())
  }

}
