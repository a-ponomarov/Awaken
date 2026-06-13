//
//  AppFont.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/10/2026.
//

import SwiftUI

enum AppFont {

  // MARK: - Display

  static let displayLarge = Font.bold(size: 75)
  static let displayMedium = Font.bold(size: 54)

  // MARK: - Title

  static let title = Font.medium(size: 20)
  static let subtitle = Font.regular(size: 17)

  // MARK: - Body

  static let body = Font.regular(size: 17)
  static let bodyMedium = Font.medium(size: 17)

  // MARK: - Caption

  static let caption = Font.regular(size: 14)
  static let captionMedium = Font.medium(size: 14)

  // MARK: - Button

  static let button = Font.semibold(size: 17)
  static let buttonSmall = Font.medium(size: 15)

  // MARK: - Input

  static let input = Font.regular(size: 20)

}
