//
//  WakeStagePickerView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct WakeStagePickerView: View {

  @Environment(Session.self) private var session
  @Environment(\.dismiss) private var dismiss
  @State private var selectedOption: WakeStageOption = .dream

  var body: some View {
    NavigationStack {
      VStack(spacing: AppLayout.vInset) {
        ForEach(WakeStageOption.allCases, id: \.self) { option in
          Button {
            selectedOption = option
            session.wakeStage = option
            dismiss()
          } label: {
            WakeStageRow(
              option: option,
              isSelected: selectedOption == option
            )
          }
          .buttonStyle(.plain)
        }
        .navigationTitle(String.wakeDuring)
      }
      .padding(.horizontal, AppLayout.cardPadding)
    }
    .background(AppColors.blue.ignoresSafeArea())
    .task {
      selectedOption = session.wakeStage
    }
  }

}

private struct WakeStageRow: View {

  let option: WakeStageOption
  let isSelected: Bool

  var body: some View {
    HStack {
      VStack {
        Text(option.leadingText)
          .foregroundStyle(AppColors.tint)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(option.trailingText)
          .foregroundStyle(AppColors.textPrimary)
          .minimumScaleFactor(0.5)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .font(AppFont.caption)
      
      Spacer()
      
      if isSelected {
        Image(systemName: "checkmark.circle")
          .font(AppFont.title)
          .foregroundStyle(AppColors.tint)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(AppLayout.cardPadding)
    .cardStyle()
  }

}
