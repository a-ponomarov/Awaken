//
//  Note.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 6/10/2026.
//

import Foundation
import SwiftData

@Model
final class Note {

  var id = UUID()
  @Relationship(deleteRule: .cascade, inverse: \Dream.note)
  var dreams: [Dream] = []
  var title: String?
  var text: String?
  var createdAt = Date()
  var updatedAt: Date?

  init(
    title: String? = nil,
    text: String? = nil
  ) {
    self.title = title
    self.text = text
  }

}
