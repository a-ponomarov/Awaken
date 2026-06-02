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
    #if os(watchOS)
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
    #else
    List {
      RecordButton()
        .frame(maxWidth: .infinity)
        .listRowInsets(AppLayout.rowInsets)
        .listRowBackground(Color.clear)
        #if os(iOS)
        .listRowSeparator(.hidden)
        #endif

      ForEach(dreams, id: \.self) { dream in
        DreamRow(dream: dream, showsDetails: false, audioPlayer: audioPlayer)
          .contentShape(.rect)
          .listRowInsets(AppLayout.rowItemInsets)
          .listRowBackground(Color.clear)
          #if os(iOS)
          .listRowSeparator(.hidden)
          .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: { onDelete(dream) }) {
              Image(systemName: "trash")
            }
            .tint(.clear)
          }
          #endif
          .onTapGesture {
            onSelect(dream)
          }
      }
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .scrollIndicators(.hidden)
    #endif
  }

}
