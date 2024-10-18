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
    @Published var isSoundOn: Bool {
        didSet {
            saveSoundState()
            // Если состояние изменилось, сразу обновляем воспроизведение
            handleMusicPlayback()
        }
    }
    
    init() {
        // Загружаем сохраненное состояние звука
        isSoundOn = UserDefaults.standard.bool(forKey: "isSoundOn")
        
        // Настраиваем аудиоплеер
        setupPlayer()
        
        // Запускаем или останавливаем музыку в зависимости от сохраненного состояния
        handleMusicPlayback()
    }
    
    // Настраиваем аудиоплеер
    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
        } catch {
            print("Не удалось настроить плеер: \(error.localizedDescription)")
        }
    }
    
    // Запускаем или останавливаем музыку в зависимости от состояния
    func handleMusicPlayback() {
        if isSoundOn {
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    // Music toggle
    func toggleSound() {
        isSoundOn.toggle()
    }
    
    // Save sound state to UserDefaults
    private func saveSoundState() {
        UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
    }
}
