import Foundation
import AVFoundation
import SwiftUI
import UIKit

protocol AudioPlaying {
    func playPrimary(named soundName: String)
    func playPrimarySlow(named soundName: String)
    func playSecondary(named soundName: String)
    func playSecondarySlow(named soundName: String)
}

final class DefaultAudioPlayerService: AudioPlaying {
    private var primaryPlayer: AVAudioPlayer?
    private var secondaryPlayer: AVAudioPlayer?
    private let queue: DispatchQueue
    
    init(queue: DispatchQueue = .main) {
        self.queue = queue
    }
    
    func playPrimary(named soundName: String) {
        play(named: soundName, delay: 0, channel: .primary)
    }
    
    func playPrimarySlow(named soundName: String) {
        play(named: soundName, delay: 1.0, channel: .primary)
    }
    
    func playSecondary(named soundName: String) {
        play(named: soundName, delay: 0, channel: .secondary)
    }
    
    func playSecondarySlow(named soundName: String) {
        play(named: soundName, delay: 1.0, channel: .secondary)
    }
    
    private func play(named soundName: String, delay: TimeInterval, channel: AudioChannel) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            return
        }
        
        queue.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            do {
                let player = try AVAudioPlayer(data: soundFile.data)
                switch channel {
                case .primary:
                    self.primaryPlayer = player
                    self.primaryPlayer?.play()
                case .secondary:
                    self.secondaryPlayer = player
                    self.secondaryPlayer?.play()
                }
            } catch {
                print("Failed to load the sound: \(error)")
            }
        }
    }
    
    private enum AudioChannel {
        case primary
        case secondary
    }
}
