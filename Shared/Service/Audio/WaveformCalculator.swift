//
//  WaveformCalculator.swift
//  Time
//
//  Created by Andrew Ponomarov on 5/5/2026.
//

import AVFoundation
import Foundation

nonisolated
struct WaveformCalculator {

  private static let minSampleCount = 10

  static func extract(from url: URL, density: Double = 0.05) -> [Float] {
    guard let audioFile = try? AVAudioFile(forReading: url),
      let buffer = AVAudioPCMBuffer(
        pcmFormat: audioFile.processingFormat,
        frameCapacity: .init(audioFile.length)
      ) else { return [] }

    let duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
    let sampleCount = max(Int(duration / density), minSampleCount)

    try? audioFile.read(into: buffer)

    guard let channelData = buffer.floatChannelData?[0] else { return [] }

    let totalSamples = Int(buffer.frameLength)
    let strideSize = max(totalSamples / sampleCount, 1)

    var result = [Float]()
    for i in stride(from: 0, to: totalSamples, by: strideSize) {
      result.append(abs(channelData[i]))
    }

    let maxValue = result.max() ?? 1
    return result.map { $0 / maxValue }
  }

}
