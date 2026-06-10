//
//  DreamsList.swift
//  Awaken
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import SwiftUI

struct DreamsList: View {

  let dreams: [Dream]
  let onSelect: (Dream) -> Void
  let onDelete: (Dream) -> Void
  
  @Environment(AudioPlayer.self) private var audioPlayer

  var body: some View {
    WatchList(
      dreams,
      id: \.self,
      header: {
        RecordButton()
          .frame(maxWidth: .infinity)
      },
      rowContent: { dream in
        DreamRow(dream: dream, showsDetails: false, audioPlayer: audioPlayer)
          .contentShape(.rect)
          .onTapGesture {
            onSelect(dream)
          }
      }
    )
  }

}
