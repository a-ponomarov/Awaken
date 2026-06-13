//
//  HourMinutePicker.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct HourMinutePicker: View {

  @Binding var hour: Int
  @Binding var minute: Int
  @Binding var isAM: Bool
  let is12HourFormat: Bool

  private let minuteRange = Array(0 ..< 60)

  private var hourRange: [Int] {
    is12HourFormat ? Array(1 ... 12) : Array(0 ..< 24)
  }

  var body: some View {
    HStack(spacing: 8) {
      TimeComponentPicker(
        values: hourRange,
        selection: $hour,
        isHour: true,
        is12HourFormat: is12HourFormat,
        isAM: $isAM
      )

      Text(verbatim: ":")
        .font(.light(size: 16))

      TimeComponentPicker(
        values: minuteRange,
        selection: $minute,
        isHour: false,
        is12HourFormat: is12HourFormat,
        isAM: $isAM
      )
    }
    .labelsHidden()
    .padding()
  }

}
