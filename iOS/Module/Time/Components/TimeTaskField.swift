//
//  TimeTaskField.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimeTaskField: View {

  @Binding var taskName: String
  let isEditable: Bool
  let onClearTaskName: () -> Void
  @FocusState private var isFocused: Bool

  var body: some View {
    TimeTextField(
      title: String.timeTaskPlaceholder,
      text: $taskName,
      autocapitalization: .never,
      isEnabled: isEditable,
      focus: $isFocused,
      onSubmit: {
        isFocused = false
      },
      onClear: onClearTaskName
    )
  }

}
