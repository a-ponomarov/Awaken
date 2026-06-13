//
//  TimePickerButton.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimePickerButton: View {

  @Binding var date: Date

  @State private var presentTimePicker = false

  var body: some View {
    Button {
      presentTimePicker = true
    } label: {
      Text(date.time)
        .font(.light(size: 22))
        .foregroundStyle(.white)
    }
    .buttonStyle(.plain)
    .sheet(isPresented: $presentTimePicker) {
      TimePicker(time: date) { selectedDate in
        date = selectedDate
      }
    }
  }

}
