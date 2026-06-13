//
//  TimeFormatButton.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct TimeFormatButton: View {

  let format: TimeFormat
  @Binding var isAM: Bool

  var body: some View {
    let isSelected = format == .am && isAM || format == .pm && !isAM
    Button {
      isAM = format == .am
    } label: {
      let tint = Color.white.opacity(0.77)
      Text(format.rawValue.uppercased())
        .bold(isSelected)
        .foregroundStyle(isSelected ? .black : tint)
        .padding(.horizontal, 2)
        .background(
          tint
            .cornerRadius(4)
            .opacity(isSelected ? 1 : 0)
        )
    }
    .buttonStyle(.plain)
  }

}
