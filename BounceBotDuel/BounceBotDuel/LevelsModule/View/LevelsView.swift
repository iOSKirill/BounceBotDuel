//
//  LevelsView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 10.10.24.
//

import SwiftUI
import SpriteKit


class LevelsScene: SKScene {
    override func didMove(to view: SKView) {
        // Устанавливаем фоновое изображение
        let background = SKSpriteNode(imageNamed: "Block5")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -1 // Устанавливаем фон на задний план
        addChild(background)
        
        // Добавляем уровни как кнопки
        createLevelButtons()
    }
    
    func createLevelButtons() {
        // Настраиваем точные позиции для уровней
        let levelPositions: [CGPoint] = [
            CGPoint(x: size.width * 0.18, y: size.height * 1),  // Позиция уровня 1
            CGPoint(x: size.width * 0.82, y: size.height * 0.92),  // Позиция уровня 2
            CGPoint(x: size.width * 0.31, y: size.height * 0.847), // Позиция уровня 3
            CGPoint(x: size.width * 0.75, y: size.height * 0.45), // Позиция уровня 4
            CGPoint(x: size.width * 0.25, y: size.height * 0.33), // Позиция уровня 5
            CGPoint(x: size.width * 0.7, y: size.height * 0.2),   // Позиция уровня 6
            CGPoint(x: size.width * 0.3, y: size.height * 0.1),   // Позиция уровня 7
            CGPoint(x: size.width * 0.75, y: size.height * 0.05), // Позиция уровня 8
            CGPoint(x: size.width * 0.5, y: size.height * 0.02)   // Позиция уровня 9
        ]
        
        for (index, position) in levelPositions.enumerated() {
            let levelButton = SKSpriteNode(imageNamed: "Level\(index + 1)")
            levelButton.position = position
            levelButton.name = "Level\(index + 1)" // Задаем имя для каждой кнопки
            levelButton.setScale(1) // Настраиваем масштаб кнопки
            levelButton.zPosition = 1 // Устанавливаем на передний план
            addChild(levelButton)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for node in nodesAtPoint {
            if let nodeName = node.name {
                handleLevelSelection(levelName: nodeName)
            }
        }
    }
    
    func handleLevelSelection(levelName: String) {
        print("\(levelName) tapped")
    }
}




import SwiftUI
import SpriteKit

struct LevelsView: View {
    @Environment(\.dismiss) var dismiss
    
    var scene: SKScene {
        let scene = LevelsScene()
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 2) // Сцена в два раза больше высоты экрана
        scene.scaleMode = .aspectFill
        return scene
    }
    
    private var topPadding: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight <= 667 ? 100 : 60
    }
    
    var navigationBar: some View {
        HStack {
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(.menuButton)
            }
        }
        .padding(.horizontal, 24)
    }
    
    var body: some View {
        ZStack {
            Image(.background1)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack {
                    navigationBar
                        .padding(.top, geometry.safeAreaInsets.top + topPadding)
                    
                    Spacer()

                    ScrollView {
                        SpriteView(scene: scene)
                            .frame(width: geometry.size.width, height: geometry.size.height * 2)
                            .background(Color.clear)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    LevelsView()
}

