//
//  TimeFormatPicker.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimeFormatPicker: View {

  @Binding var isAM: Bool

  var body: some View {
    VStack {
      Spacer()
      TimeFormatButton(format: .am, isAM: $isAM)
      Spacer()
      TimeFormatButton(format: .pm, isAM: $isAM)
      Spacer()
    }
  }

}
