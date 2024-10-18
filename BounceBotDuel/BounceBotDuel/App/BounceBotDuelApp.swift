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
    @StateObject private var viewModel = ShopViewModel()
    
    // MARK: - Body -
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environmentObject(soundManager)
                .environmentObject(viewModel)
                .onAppear {
                    soundManager.handleMusicPlayback()
                }
        }
    }
}
