//
//  AppLayout.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/10/2026.
//

import SwiftUI

enum AppLayout {

  // MARK: - Spacing

  static let spacing: CGFloat = 4

  // MARK: - Stroke

  static let stroke: CGFloat = 0.5

  // MARK: - Screen
  
  #if os(watchOS)
  static let vInset: CGFloat = 8
  static let cardPadding: CGFloat = vInset
  #else
  static let vInset: CGFloat = 10
  static let cardPadding: CGFloat = 1.6 * vInset
  #endif

  static let cardRadius: CGFloat = 1.6 * vInset
  
  static let rowInsets = EdgeInsets(
    top: 0,
    leading: cardPadding,
    bottom: vInset,
    trailing: cardPadding
  )
  
  static let rowItemInsets = EdgeInsets(
    top: vInset / 2,
    leading: cardPadding,
    bottom: vInset / 2,
    trailing: cardPadding
  )

}
