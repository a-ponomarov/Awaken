//
//  TimeTextField.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/9/2026.
//

import SwiftUI

struct TimeTextField: View {

  private enum Constants {

    static let clearButtonIconFontSize: CGFloat = 18
    static let clearButtonTrailingPadding: CGFloat = 18
    static let textTrailingPadding: CGFloat = 48
    static let minHeight: CGFloat = 60
    static let leadingPadding: CGFloat = minHeight * 0.5

  }

  let title: String
  @Binding var text: String
  let autocapitalization: TextInputAutocapitalization?
  let isEnabled: Bool
  let focus: FocusState<Bool>.Binding
  let onSubmit: () -> Void
  let onClear: () -> Void

  var body: some View {
    ZStack(alignment: .trailing) {
      TextField(
        "",
        text: $text,
        prompt: Text(title).foregroundStyle(AppColors.textSecondary)
      )
      .textInputAutocapitalization(autocapitalization)
      .autocorrectionDisabled()
      .font(AppFont.input)
      .foregroundStyle(AppColors.textPrimary)
      .submitLabel(.done)
      .padding(.leading, Constants.leadingPadding)
      .padding(.trailing, Constants.textTrailingPadding)
      .frame(height: Constants.minHeight)
      .focused(focus)
      .onSubmit(onSubmit)
      .disabled(!isEnabled)

      if isEnabled && !text.isEmpty {
        Button(action: onClear) {
          Image(systemName: "xmark.circle.fill")
            .font(.regular(size: Constants.clearButtonIconFontSize))
            .foregroundStyle(AppColors.textSecondary)
        }
        .buttonStyle(.plain)
        .padding(.trailing, Constants.clearButtonTrailingPadding)
        .frame(maxHeight: .infinity, alignment: .center)
      }
    }
    .frame(height: Constants.minHeight)
    .background(
      Capsule()
        .fill(AppColors.surface)
    )
    .overlay {
      Capsule()
        .stroke(AppColors.tint, lineWidth: AppLayout.stroke)
    }
  }

}
