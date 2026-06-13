//
//  TimePicker.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimePicker: View {

  private enum Constants {
    static let pickerWidthRatio: CGFloat = 0.77
    static let pickerHeight: CGFloat = 66
  }

  @State private var model: TimePickerModel

  @Environment(\.dismiss) private var dismiss

  init(time: Date, completion: @escaping (Date) -> Void) {
    _model = State(initialValue: TimePickerModel(time: time))
    self.completion = completion
  }

  private let completion: (Date) -> Void

  var body: some View {
    @Bindable var bindableModel = model

    GeometryReader { geometry in
      ZStack {
        AppColors.background.ignoresSafeArea()
        ClockView(
          hour: model.hour,
          minute: model.minute,
          is12HourFormat: model.is12HourFormat
        )
        HourMinutePicker(
          hour: $bindableModel.hour,
          minute: $bindableModel.minute,
          isAM: $bindableModel.isAM,
          is12HourFormat: model.is12HourFormat
        )
        .frame(
          width: geometry.size.width * Constants.pickerWidthRatio,
          height: Constants.pickerHeight
        )
        if model.is12HourFormat {
          TimeFormatPicker(isAM: $bindableModel.isAM)
        }
      }
    }
    .padding(.top, 22)
    .ignoresSafeArea()
    .toolbar {
      ConfirmationToolbarItem {
          completion(model.confirmSelection())
          dismiss()
      }
    }
  }

}

#Preview {
  TimePicker(time: Date(), completion: { _ in })
}
