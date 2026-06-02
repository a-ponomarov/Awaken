//
//  AlarmKitMetadata.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AlarmKit
import Foundation

struct CountdownLiveActivityMetadata: AlarmMetadata, Codable, Sendable {

  let taskName: String?

}
