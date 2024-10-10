//
//  BounceBotDuelApp.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 9.10.24.
//

import SwiftUI

@main
struct BounceBotDuelApp: App {
    // MARK: - Property -
    @StateObject private var soundManager = SoundManager.shared
    
    // MARK: - Body -
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environmentObject(soundManager)
                .onAppear {
                    soundManager.playBackgroundMusic()
                }
        }
    }
}
