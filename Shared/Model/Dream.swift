//
//  Dream.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation
import SwiftData

@Model
final class Dream {

  var id = UUID()
  @Relationship var sleep: Sleep?
  @Relationship var user: User?
  var audioFilename: String?
  var isLucid: Bool = false
  var createdAt = Date()
  var waveform: [Float]?

  init(audioFilename: String, isLucid: Bool = false, sleep: Sleep? = nil) {
    self.audioFilename = audioFilename
    self.isLucid = isLucid
    self.sleep = sleep
  }

}
