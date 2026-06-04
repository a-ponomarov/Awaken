//
//  CustomDatePickerView.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct CustomDatePickerView: View {

  private enum Constants {

    static let datePickerHeight = 50.0
    static let cellSpacing = 2.0
    static let cellLabelFontSize = 9.0
    static let cellValueFontSize = 16.0

  }

  @Binding var selection: Date
  @State private var showNativeDatePicker = false
  @State private var showCustomTimePicker = false
  @State private var dateInPicker = Date()

  var body: some View {
    ZStack {
      AppColors.background
        .ignoresSafeArea()

      VStack(spacing: AppLayout.vInset) {
        pickerCell(
          label: .date,
          value: selection.formatted(date: .abbreviated, time: .omitted)
        ) {
          dateInPicker = selection
          showNativeDatePicker = true
        }

        pickerCell(
          label: .time,
          value: selection.formatted(date: .omitted, time: .shortened)
        ) {
          showCustomTimePicker = true
        }
      }
      .padding(.horizontal, AppLayout.cardPadding)
    }
    .sheet(isPresented: $showNativeDatePicker) {
      ZStack {
        AppColors.background.ignoresSafeArea()
        DatePicker(String.date, selection: $dateInPicker, displayedComponents: .date)
          .labelsHidden()
          .tint(.white)
          .frame(height: Constants.datePickerHeight)
          .padding(.horizontal, AppLayout.cardPadding)
          .toolbar {
            ConfirmationToolbarItem(action: applyDate)
          }
      }
    }
    .sheet(isPresented: $showCustomTimePicker) {
      TimePicker(time: selection) { selectedDate in
        applyTime(selectedDate)
      }
    }
  }

  private func applyDate() {
    selection = selectionBySettingTime(from: selection, on: dateInPicker)
    showNativeDatePicker = false
  }

  private func applyTime(_ time: Date) {
    selection = selectionBySettingTime(from: time, on: selection)
  }

  private func selectionBySettingTime(from time: Date, on date: Date) -> Date {
    let calendar = Calendar.current
    let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
    var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)

    guard
      let hour = timeComponents.hour,
      let minute = timeComponents.minute
    else { return date }

    dateComponents.hour = hour
    dateComponents.minute = minute
    dateComponents.second = 0

    return calendar.date(from: dateComponents) ?? date
  }

  @ViewBuilder
  private func pickerCell(
    label: String,
    value: String,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      VStack(spacing: Constants.cellSpacing) {
        Text(label)
          .font(.bold(size: Constants.cellLabelFontSize))
          .foregroundStyle(AppColors.primary)

        Text(value)
          .font(.light(size: Constants.cellValueFontSize))
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, AppLayout.cardPadding)
      .cardStyle(cornerRadius: AppLayout.cardRadius)
    }
    .buttonStyle(.plain)
  }

}

#Preview {

  CustomDatePickerView(selection: .constant(Date()))

}

struct ConfirmationToolbarItem: ToolbarContent {

  let action: () -> Void

  var body: some ToolbarContent {
    ToolbarItem(placement: .confirmationAction) {
      Button("", systemImage: "checkmark", action: action)
    }
  }

}
