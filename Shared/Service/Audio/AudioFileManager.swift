//
//  AudioFileManager.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import Foundation

nonisolated
enum AudioFileManager {

  static var dir: URL {
    guard let base = FileManager.default.urls(
      for: .documentDirectory,
      in: .userDomainMask
    ).first else {
      preconditionFailure("User document directory must exist.")
    }
    return base.appendingPathComponent("Audio", isDirectory: true)
  }

  static func fileURL(for dreamID: UUID) -> URL {
    dir.appendingPathComponent("\(dreamID.uuidString).m4a")
  }

  static func ensureSetup() throws {
    try FileManager.default.createDirectory(
      at: dir,
      withIntermediateDirectories: true
    )
  }

}
