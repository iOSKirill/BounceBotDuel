//
//  GameView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 11.10.24.
//

import SpriteKit
import SwiftUI
import Combine

struct GameView: View {
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.dismiss) var dismiss
    @State private var roundCoins = 0
    @State private var currentScene: GameScene?

    var level: Int // Получаем уровень как параметр

    var scene: SKScene {
        let scene = GameScene(soundManager: soundManager, shopViewModel: ShopViewModel(), winCallback: { coins in
            roundCoins = coins
        }, loseCallback: {})

        scene.currentLevel = level // Устанавливаем уровень в сцене
        scene.dismissCallback = {
            dismiss()
        }

        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene.scaleMode = .resizeFill
        return scene
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GameView(level: 1)
        .environmentObject(SoundManager())
}
