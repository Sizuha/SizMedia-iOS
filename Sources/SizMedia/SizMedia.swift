import Foundation
import AVFoundation
import Accelerate
import UIKit

/// Audioデータ（wav）をロードする。
/// - Parameters:
///   - audioFile: wavファイル
///   - sampleRate: Sample Rate
///   - channels: count of channels
///   - interleaved: interleaved (true / false)
/// - Returns: Audio Dataの配列
func loadAudioSamplesArrayOf(audioFile file: AVAudioFile, sampleRate: Int, channels: Int = 1, interleaved: Bool = true) -> [Double]? {
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32 /*.pcmFormatInt16*/, sampleRate: Double(sampleRate), channels: AVAudioChannelCount(channels), interleaved: interleaved)
    
    if let buffer = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(file.length)){
        if let _ = try? file.read(into: buffer) {
            let arraySize = Int(buffer.frameLength)
            
            let doublePointer = UnsafeMutablePointer<Double>.allocate(capacity: arraySize)
            vDSP_vspdp(buffer.floatChannelData![0], 1, doublePointer, 1, vDSP_Length(arraySize))
            return Array(UnsafeBufferPointer(start: doublePointer, count:arraySize))
        }
        else {
            print("ERROR HERE")
        }
    }
    
    return nil
}

public func convertToWav(from fromPath: URL, to toPath: URL, options: AKConverter.Options, onComplete: @escaping (_ result: Bool)->Void) {
    let converter = AKConverter(inputURL: fromPath, outputURL: toPath, options: options)
    converter.start(completionHandler: { error in
        onComplete(error != nil)
    })
}
