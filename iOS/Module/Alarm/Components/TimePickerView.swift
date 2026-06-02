//
//  TimePickerView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimePickerView: View {

  private enum Constants {

    static let pickerHeight: CGFloat = 300

  }

  @Binding var selectedTime: Date
  @State private var tempTime: Date
  @Environment(\.dismiss) private var dismiss

  private let onConfirm: (Date) -> Void

  init(selectedTime: Binding<Date>, onConfirm: @escaping (Date) -> Void) {
    self._selectedTime = selectedTime
    self._tempTime = State(initialValue: selectedTime.wrappedValue)
    self.onConfirm = onConfirm
  }

  var body: some View {
    NavigationStack {
      DatePicker(
        "",
        selection: $tempTime,
        displayedComponents: .hourAndMinute
      )
      .datePickerStyle(.wheel)
      .labelsHidden()
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(String.done) {
            let time = tempTime.nextOccurrence()
            selectedTime = time
            onConfirm(time)
            dismiss()
          }.tint(.white)
        }

        ToolbarItem(placement: .cancellationAction) {
          Button(String.cancel) {
            dismiss()
          }.tint(.white)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
    }
    .presentationDetents([.height(Constants.pickerHeight)])
    .presentationDragIndicator(.hidden)
    .background(AppColors.blue.ignoresSafeArea())
  }

}
