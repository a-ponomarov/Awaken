//
//  TimeComponentPicker.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimeComponentPicker: View {

  private enum Constants {

    static let loopCount = 3

  }

  let values: [Int]
  @Binding var selection: Int
  var isHour = false
  var is12HourFormat = false
  @Binding var isAM: Bool

  @State private var index = 0
  @State private var previousValue = 0

  private var loopedValues: [Int] {
    Array(repeating: values, count: Constants.loopCount).flatMap { $0 }
  }

  var body: some View {
    Picker("", selection: $index) {
      ForEach(loopedValues.indices, id: \.self) { i in
        Text(String(format: "%02d", loopedValues[i]))
          .font(.light(size: 24))
          .tag(i)
      }
    }
    .onAppear {
      index = centeredIndex(for: selection)
      previousValue = selection
    }
    .onChange(of: index) { _, newValue in
      let selectedValue = loopedValues[newValue % values.count]
      if isHour && is12HourFormat {
        if previousValue == 11 && selectedValue == 12 {
          isAM.toggle()
        } else if previousValue == 12 && selectedValue == 11 {
          isAM.toggle()
        }
        previousValue = selectedValue
      }

      selection = selectedValue

      if newValue < values.count || newValue > loopedValues.count - values.count {
        index = centeredIndex(for: selection)
      }
    }
  }

  private func centeredIndex(for value: Int) -> Int {
    let middle = loopedValues.count / 2
    let base = middle - (middle % values.count)
    guard let offset = values.firstIndex(of: value) else { return base }
    return base + offset
  }

}
