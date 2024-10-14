//
//  LevelsView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 14.10.24.
//

import SpriteKit
import SwiftUI

struct LevelsView: View {
    // MARK: - Property -
    @Environment(\.dismiss) var dismiss
    @State private var selectedLevel: Int? = nil // Состояние для выбранного уровня

    var scene: SKScene {
        let scene = LevelsScene(fileNamed: "LevelsScene")!
        scene.dismissCallback = {
            dismiss()
        }
        scene.levelSelectedCallback = { level in
            selectedLevel = level // Устанавливаем выбранный уровень
        }
        scene.shopViewModel = ShopViewModel()
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene.scaleMode = .resizeFill
        return scene
    }

    // MARK: - Body -
    var body: some View {
        NavigationView {
            ZStack {
                SpriteView(scene: scene)
                    .ignoresSafeArea()

                // Навигация на GameView, если уровень выбран
                NavigationLink(
                    destination: GameView(level: selectedLevel ?? 1),
                    isActive: Binding(
                        get: { selectedLevel != nil },
                        set: { _ in selectedLevel = nil }
                    )
                ) {
                    EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

