//
//  SoundManager.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 10.10.24.
//

import AVFoundation
import SwiftUI

class SoundManager: ObservableObject {
    // MARK: - Property -
    static let shared = SoundManager()
    
    var player: AVAudioPlayer?
    @Published var isSoundOn: Bool = true
    
    private init() {}
    
    // Play music game
    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            print("Не удалось воспроизвести музыку: \(error.localizedDescription)")
        }
    }
    
    // Music toggle
    func toggleSound() {
        isSoundOn.toggle()
        
        if isSoundOn {
            player?.play()
        } else {
            player?.pause()
        }
    }
}
