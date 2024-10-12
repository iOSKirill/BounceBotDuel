//
//  GameView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 11.10.24.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var soundManager: SoundManager

    var scene: SKScene {
        let scene = GameScene(soundManager: soundManager)
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
    GameView()
        .environmentObject(SoundManager())
}


import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var soundManager: SoundManager
    var capsule: SKSpriteNode!
    var coin: SKSpriteNode!
    var playerBall: SKSpriteNode!
    var botBall: SKSpriteNode!
    var obstacles: [SKSpriteNode] = []
    var ballInPlay = false
    var playerScore = 0
    var playerScoreLabel: SKLabelNode!
    var playerNameLabel: SKLabelNode!
    var pauseButton: SKSpriteNode!
    var settingsPanel: SKSpriteNode!
    var soundButton: SKSpriteNode!
    var restartButton: SKSpriteNode!
    var homeButton: SKSpriteNode!
    var background: SKSpriteNode!
    var isSettingsPanelVisible = false
    var level = 1 // Текущий уровень
    var botScore = 0
    var botScoreLabel: SKLabelNode!
    var botAttemptCount = 0

    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let playerBall: UInt32 = 0b1
        static let botBall: UInt32 = 0b10
        static let coin: UInt32 = 0b100
    }
    
    // Массив с фиксированными позициями для первого уровня
    let level1Pins: [CGPoint] = [
        CGPoint(x: 120, y: 700),
        CGPoint(x: 200, y: 700),
        CGPoint(x: 280, y: 700),
        CGPoint(x: 360, y: 700),
        
        CGPoint(x: 160, y: 640),
        CGPoint(x: 240, y: 640),
        CGPoint(x: 320, y: 640),

        CGPoint(x: 120, y: 580),
        CGPoint(x: 200, y: 580),
        CGPoint(x: 280, y: 580),
        CGPoint(x: 360, y: 580),

        CGPoint(x: 160, y: 520),
        CGPoint(x: 240, y: 520),
        CGPoint(x: 320, y: 520),

        CGPoint(x: 120, y: 460),
        CGPoint(x: 200, y: 460),
        CGPoint(x: 280, y: 460),
        CGPoint(x: 360, y: 460),
    ]

    // MARK: - Initializer with SoundManager
    init(soundManager: SoundManager) {
        self.soundManager = soundManager
        super.init(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        setupBackground()
        setupCapsule()
        setupObstaclesForLevel()
        setupCoinForLevel()
        setupScoreLabel()
        setupBotScoreLabel()  // Добавляем отображение счета бота
        setupPlayerNameLabel()
        setupPauseButton()
        physicsWorld.gravity = CGVector(dx: 0, dy: -4.8)
        physicsWorld.contactDelegate = self
    }

    // Setup Background
    func setupBackground() {
        background = SKSpriteNode(imageNamed: "Background1")
        background.size = self.size
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.zPosition = -1
        addChild(background)
    }
    
    // Setup Player Name label
    func setupPlayerNameLabel() {
        playerNameLabel = SKLabelNode(text: "Player")
        playerNameLabel.fontSize = 20
        playerNameLabel.fontColor = .white
        playerNameLabel.position = CGPoint(x: size.width * 0.2, y: size.height - 50)
        addChild(playerNameLabel)
    }

    // Setup Score Label
    func setupScoreLabel() {
        playerScoreLabel = SKLabelNode(text: "Score: \(playerScore)")
        playerScoreLabel.fontSize = 24
        playerScoreLabel.fontColor = .white
        playerScoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(playerScoreLabel)
    }
    
    func setupBotScoreLabel() {
        botScoreLabel = SKLabelNode(text: "Bot Score: \(botScore)")
        botScoreLabel.fontSize = 24
        botScoreLabel.fontColor = .white
        botScoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 140)
        addChild(botScoreLabel)
    }
    
    // Setup Pause Button
    func setupPauseButton() {
        pauseButton = SKSpriteNode(imageNamed: "PauseButton")
        pauseButton.position = CGPoint(x: size.width - 50, y: size.height - 50)
        addChild(pauseButton)
    }
    
    // Setup Capsule where balls drop from
    func setupCapsule() {
        capsule = SKSpriteNode(imageNamed: "Pipe")
        capsule.position = CGPoint(x: size.width / 2, y: size.height - 50)
        addChild(capsule)
    }

    // Setup obstacles (pins) for level 1
    func setupObstaclesForLevel() {
        for position in level1Pins {
            let peg = SKSpriteNode(imageNamed: "Pin")
            peg.size = CGSize(width: 20, height: 20)
            peg.position = position
            peg.physicsBody = SKPhysicsBody(circleOfRadius: peg.size.width / 2)
            peg.physicsBody?.isDynamic = false
            peg.physicsBody?.restitution = 0.8
            addChild(peg)
            obstacles.append(peg)
        }
    }
    
    // Setup coin for level 1
    func setupCoinForLevel() {
        // Выбираем случайное место для монеты
        let randomIndex = Int.random(in: 0..<level1Pins.count)
        let coinPosition = level1Pins[randomIndex]
        
        coin = SKSpriteNode(imageNamed: "Coin")
        coin.position = coinPosition
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.playerBall | PhysicsCategory.botBall
        addChild(coin)
    }
    
    // Setup coin for level 1
    func generateNewCoin() {
        // Удаляем старую монету, если она существует
        coin?.removeFromParent()
        
        // Выбираем случайное место для новой монеты
        let randomIndex = Int.random(in: 0..<level1Pins.count)
        let coinPosition = level1Pins[randomIndex]
        
        coin = SKSpriteNode(imageNamed: "Coin")
        coin.position = coinPosition
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.playerBall | PhysicsCategory.botBall
        addChild(coin)
    }

    
    // Launch balls (player & bot)
    func launchBalls() {
        guard !ballInPlay else { return }
        
        // Player Ball
        playerBall = SKSpriteNode(imageNamed: "PlayerBall")
        playerBall.position = capsule.position
        playerBall.physicsBody = SKPhysicsBody(circleOfRadius: playerBall.size.width / 2)
        playerBall.physicsBody?.restitution = 0.5
        playerBall.physicsBody?.linearDamping = 1.0
        playerBall.physicsBody?.categoryBitMask = PhysicsCategory.playerBall
        playerBall.physicsBody?.contactTestBitMask = PhysicsCategory.coin
        addChild(playerBall)
        
        // Bot Ball
        botBall = SKSpriteNode(imageNamed: "BotBall")
        botBall.position = capsule.position
        botBall.physicsBody = SKPhysicsBody(circleOfRadius: botBall.size.width / 2)
        botBall.physicsBody?.restitution = 0.5
        botBall.physicsBody?.linearDamping = 1.0
        botBall.physicsBody?.categoryBitMask = PhysicsCategory.botBall
        addChild(botBall)
        
        // Увеличиваем счетчик попыток бота
        botAttemptCount += 1

        // Логика для бота
        if botAttemptCount % 3 == 0 {
            // Если это третья попытка, бот точно попадает в монету
            let dx = (coin.position.x - botBall.position.x) * 0.03  // Уменьшаем силу по оси X
            let dy = (coin.position.y - botBall.position.y) * 0.02  // Также добавляем контроль по оси Y
            botBall.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy)) // Точное попадание в монету
        } else {
            // Если это не третья попытка, бот может промахнуться
            botBall.physicsBody?.applyImpulse(CGVector(dx: CGFloat.random(in: -2...2), dy: -5))
        }
        
        // Логика для игрока (чаще попадает)
        let playerShouldHit = Int.random(in: 1...5) <= 4 // Игрок попадает в 4 из 5 попыток
        
        if playerShouldHit {
            // Игрок точно попадает в монету
            let dx = (coin.position.x - playerBall.position.x) * 0.03  // Уменьшаем силу по оси X
            let dy = (coin.position.y - playerBall.position.y) * 0.02  // Также добавляем контроль по оси Y
            playerBall.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy)) // Точное попадание в монету
        } else {
            // Иногда игрок может промахнуться
            playerBall.physicsBody?.applyImpulse(CGVector(dx: CGFloat.random(in: -1...1), dy: -5))
        }
        
        ballInPlay = true
    }

    // Handle Touches to Launch Balls
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if pause button is pressed
        if pauseButton.contains(location) {
            toggleSettingsPanel()
        } else if !isSettingsPanelVisible {
            // Launch balls if the settings panel is not visible
            launchBalls()
        }
    }

    // Toggle Settings Panel
    func toggleSettingsPanel() {
        isSettingsPanelVisible.toggle()
        if isSettingsPanelVisible {
            showSettingsPanel()
        } else {
            hideSettingsPanel()
        }
    }

    // Show Settings Panel
    func showSettingsPanel() {
        settingsPanel = SKSpriteNode(color: .black, size: CGSize(width: size.width * 0.8, height: size.height * 0.3))
        settingsPanel.alpha = 0.5
        settingsPanel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(settingsPanel)
        
        // Home Button
        homeButton = SKSpriteNode(imageNamed: "HomeButton")
        homeButton.position = CGPoint(x: settingsPanel.position.x - 60, y: settingsPanel.position.y)
        addChild(homeButton)
        
        // Restart Button
        restartButton = SKSpriteNode(imageNamed: "RestartButton")
        restartButton.position = CGPoint(x: settingsPanel.position.x, y: settingsPanel.position.y)
        addChild(restartButton)
        
        // Sound Button
        soundButton = SKSpriteNode(imageNamed: soundManager.isSoundOn ? "SoundOnButton" : "SoundOffButton")
        soundButton.position = CGPoint(x: settingsPanel.position.x + 60, y: settingsPanel.position.y)
        addChild(soundButton)
    }

    // Hide Settings Panel
    func hideSettingsPanel() {
        settingsPanel.removeFromParent()
        homeButton.removeFromParent()
        restartButton.removeFromParent()
        soundButton.removeFromParent()
    }

    // Handle Ball-coin collision
    // Handle Ball-coin collision
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        // Столкновение игрока с монетой
        if (firstBody.categoryBitMask == PhysicsCategory.playerBall && secondBody.categoryBitMask == PhysicsCategory.coin) ||
           (firstBody.categoryBitMask == PhysicsCategory.coin && secondBody.categoryBitMask == PhysicsCategory.playerBall) {
            playerScore += 1
            updateScore()
            
            // Удаляем монету из сцены
            if secondBody.categoryBitMask == PhysicsCategory.coin {
                secondBody.node?.removeFromParent()
            } else if firstBody.categoryBitMask == PhysicsCategory.coin {
                firstBody.node?.removeFromParent()
            }
        }
        
        // Столкновение бота с монетой
        if (firstBody.categoryBitMask == PhysicsCategory.botBall && secondBody.categoryBitMask == PhysicsCategory.coin) ||
           (firstBody.categoryBitMask == PhysicsCategory.coin && secondBody.categoryBitMask == PhysicsCategory.botBall) {
            botScore += 1
            updateBotScore()
            
            // Удаляем монету из сцены
            if secondBody.categoryBitMask == PhysicsCategory.coin {
                secondBody.node?.removeFromParent()
            } else if firstBody.categoryBitMask == PhysicsCategory.coin {
                firstBody.node?.removeFromParent()
            }
        }
    }


    func updateBotScore() {
        botScoreLabel.text = "Bot Score: \(botScore)"
    }

    // Update Score Display
    func updateScore() {
        playerScoreLabel.text = "Score: \(playerScore)"
    }

    override func update(_ currentTime: TimeInterval) {
        // Проверяем, если оба шара упали за пределы экрана
        if ballInPlay && playerBall.position.y < 0 && botBall.position.y < 0 {
            ballInPlay = false
            playerBall.removeFromParent()
            botBall.removeFromParent()

            // Генерация новой монеты только после окончания броска
            generateNewCoin()
        }
    }

}
