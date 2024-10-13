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
    
    @StateObject private var viewModel = GameViewModel()

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
    var playerAvatar: SKSpriteNode!
    var scoreBoard: SKSpriteNode!
    var isSettingsPanelVisible = false
    var level = 1
    var botScore = 0
    var botScoreLabel: SKLabelNode!
    var botAttemptCount = 0
    
    var playerLives = 3
    var lifeIndicator: SKSpriteNode!
    
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let playerBall: UInt32 = 0b1
        static let botBall: UInt32 = 0b10
        static let coin: UInt32 = 0b100
    }

    let level1RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3), CGPoint(x: 2, y: 3),
        CGPoint(x: -1.5, y: 2.5), CGPoint(x: -0.5, y: 2.5), CGPoint(x: 0.5, y: 2.5), CGPoint(x: 1.5, y: 2.5),
        CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2), CGPoint(x: 2, y: 2),
        CGPoint(x: -1.5, y: 1.5), CGPoint(x: -0.5, y: 1.5), CGPoint(x: 0.5, y: 1.5), CGPoint(x: 1.5, y: 1.5),
        CGPoint(x: -2, y: 1), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1)
    ]

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
        setupScoreBoard()
        setupBotScoreLabel()
        setupPlayerNameLabel()
        setupPauseButton()
        setupPlayerLives()
        physicsWorld.gravity = CGVector(dx: 0, dy: -4.8)
        physicsWorld.contactDelegate = self
    }

    func setupBackground() {
        background = SKSpriteNode(imageNamed: "Background1")
        background.size = self.size
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.zPosition = -1
        addChild(background)
    }

    func setupPlayerNameLabel() {
        // Добавляем задний фон для аватара
        let avatarBackground = SKSpriteNode(imageNamed: "Block3")
        avatarBackground.size = CGSize(width: 60, height: 60) // Фон чуть больше аватара
        avatarBackground.position = CGPoint(x: size.width * 0.1, y: size.height - 170) // Тот же центр, что и у аватара
        addChild(avatarBackground)
        
        // Добавляем аватар
        let playerAvatarTexture = SKTexture(imageNamed: viewModel.playerAvatar)
        playerAvatar = SKSpriteNode(texture: playerAvatarTexture)
        playerAvatar.size = CGSize(width: 45, height: 45)
        playerAvatar.position = avatarBackground.position
        playerAvatar.zPosition = 1  // Устанавливаем выше заднего фона

        // Добавляем маску для скругления углов
        let roundedAvatar = SKShapeNode(rectOf: playerAvatar.size, cornerRadius: 10) // Скругленные углы
        roundedAvatar.fillTexture = playerAvatarTexture
        roundedAvatar.fillColor = .white // Белый цвет, если что-то не покрыто текстурой
        roundedAvatar.position = CGPoint(x: playerAvatar.position.x, y: playerAvatar.position.y + 3)
        roundedAvatar.zPosition = 2

        addChild(roundedAvatar)
        
        // Добавляем имя игрока, выравнивая его по верхнему краю аватара
        playerNameLabel = SKLabelNode(text: viewModel.playerName)
        playerNameLabel.fontName = "SupercellMagic"
        playerNameLabel.fontSize = 20
        playerNameLabel.fontColor = .white
        playerNameLabel.verticalAlignmentMode = .top
        playerNameLabel.position = CGPoint(x: playerAvatar.position.x + 65, y: playerAvatar.position.y + playerAvatar.size.height / 2 + 3)
        addChild(playerNameLabel)
    }
    
    func setupScoreBoard() {
        scoreBoard = SKSpriteNode(imageNamed: "Block6")
        scoreBoard.position = CGPoint(x: size.width * 0.23, y: size.height - 100)
        scoreBoard.setScale(1.1)
        addChild(scoreBoard)
    }
    
    func setupScoreLabel() {
        let scoreCoinImage = SKSpriteNode(imageNamed: "Coin")
        scoreCoinImage.position = CGPoint(x: size.width * 0.1, y: size.height - 105)
        scoreCoinImage.setScale(0.6)
        scoreCoinImage.zPosition = 2
        addChild(scoreCoinImage)
        
        playerScoreLabel = SKLabelNode(text: "\(playerScore)")
        playerScoreLabel.fontName = "SupercellMagic"
        playerScoreLabel.fontSize = 16
        playerScoreLabel.fontColor = .cFFE500
        playerScoreLabel.position = CGPoint(x: size.width * 0.148, y: size.height - 110)
        playerScoreLabel.zPosition = 2
        addChild(playerScoreLabel)
    }

    func setupBotScoreLabel() {
        botScoreLabel = SKLabelNode(text: "\(botScore)")
        botScoreLabel.fontName = "SupercellMagic"
        botScoreLabel.fontSize = 16
        botScoreLabel.fontColor = .c00D1FF
        botScoreLabel.position = CGPoint(x: size.width * 0.325, y: size.height - 110)
        addChild(botScoreLabel)
    }

    func setupPauseButton() {
        pauseButton = SKSpriteNode(imageNamed: "PauseButton")
        pauseButton.position = CGPoint(x: size.width - 50, y: size.height - 100)
        addChild(pauseButton)
    }

    func setupCapsule() {
        capsule = SKSpriteNode(imageNamed: "Pipe")
        capsule.position = CGPoint(x: size.width / 2, y: size.height / 1.4)
        addChild(capsule)
    }

    func generateLevelPins(relativePositions: [CGPoint], screenWidth: CGFloat, maxPinsInRow: Int) -> [CGPoint] {
        let pinSpacingX = screenWidth / CGFloat(maxPinsInRow + 0)
        let pinSpacingY = pinSpacingX * 1.2
        let centerX = screenWidth / 2
        let centerY = size.height / 4.2

        return relativePositions.map { relativePos in
            let x = centerX + relativePos.x * pinSpacingX
            let y = centerY + relativePos.y * pinSpacingY
            return CGPoint(x: x, y: y)
        }
    }

    func setupObstaclesForLevel() {
        let screenWidth = self.size.width
        let maxPinsInRow = 5

        let levelPins = generateLevelPins(relativePositions: level1RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)

        for position in levelPins {
            let peg = SKSpriteNode(imageNamed: "Pin")
            peg.size = CGSize(width: 20, height: 28)
            peg.position = position
            peg.physicsBody = SKPhysicsBody(circleOfRadius: peg.size.width / 2)
            peg.physicsBody?.isDynamic = false
            peg.physicsBody?.restitution = 0.8
            addChild(peg)
            obstacles.append(peg)
        }
    }

    func setupCoinForLevel() {
        let randomIndex = Int.random(in: 0..<obstacles.count)
        let coinPosition = obstacles[randomIndex].position

        // Создаем узел для монеты
        coin = SKSpriteNode(imageNamed: "coin-1")
        coin.position = coinPosition
        coin.setScale(0.15)
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.playerBall | PhysicsCategory.botBall
        addChild(coin)

        // Создаем массив текстур для анимации от 1 до 10
        var coinTextures: [SKTexture] = []
        for i in 1...10 {
            let textureName = "coin-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            coinTextures.append(texture)
        }

        // Создаем обратную последовательность от 9 до 1 (для 11-20)
        var reverseCoinTextures: [SKTexture] = []
        for i in (1...9).reversed() {
            let textureName = "coin-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            reverseCoinTextures.append(texture)
        }

        // Объединяем все текстуры
        let fullAnimationTextures = coinTextures + reverseCoinTextures

        // Создаем анимацию для первых 10 кадров
        let forwardAnimation = SKAction.animate(with: coinTextures, timePerFrame: 0.1)

        // Анимация с переворотом от 11 до 20
        let flippedAnimation = SKAction.run { [weak self] in
            self?.coin.xScale = -0.15 // Отражаем текстуры от 11 до 20
        }
        let reverseAnimation = SKAction.animate(with: reverseCoinTextures, timePerFrame: 0.1)

        // Возвращаем нормальный масштаб
        let unflippedAnimation = SKAction.run { [weak self] in
            self?.coin.xScale = 0.15 // Восстанавливаем обычный масштаб
        }

        // Создаем последовательность анимаций
        let sequence = SKAction.sequence([forwardAnimation, flippedAnimation, reverseAnimation, unflippedAnimation])

        // Запускаем бесконечную анимацию
        let repeatAnimation = SKAction.repeatForever(sequence)
        coin.run(repeatAnimation)
    }


    func setupPlayerLives() {
        lifeIndicator = SKSpriteNode(imageNamed: "Life3")
        lifeIndicator.size = CGSize(width: 90, height: 10)
        lifeIndicator.position = CGPoint(x: playerNameLabel.position.x + 17, y: size.height - 185)
        addChild(lifeIndicator)
    }
    
    func updatePlayerLives() {
        if playerLives == 3 {
            lifeIndicator.texture = SKTexture(imageNamed: "Life3")
        } else if playerLives == 2 {
            lifeIndicator.texture = SKTexture(imageNamed: "Life2")
        } else if playerLives == 1 {
            lifeIndicator.texture = SKTexture(imageNamed: "Life1")
        }
    }

    func launchBalls() {
        guard !ballInPlay else { return } // Проверяем, что мячи не запущены

        ballInPlay = true

        // Player Ball
        playerBall = SKSpriteNode(imageNamed: "Ball1")
        playerBall.size = CGSize(width: 28, height: 28)
        playerBall.position = capsule.position
        playerBall.physicsBody = SKPhysicsBody(circleOfRadius: playerBall.size.width / 2)
        playerBall.physicsBody?.restitution = 0.5
        playerBall.physicsBody?.linearDamping = 1.0
        playerBall.physicsBody?.categoryBitMask = PhysicsCategory.playerBall
        playerBall.physicsBody?.contactTestBitMask = PhysicsCategory.coin
        addChild(playerBall)

        // Bot Ball
        botBall = SKSpriteNode(imageNamed: "BotBall")
        botBall.size = CGSize(width: 28, height: 28)
        botBall.position = capsule.position
        botBall.physicsBody = SKPhysicsBody(circleOfRadius: botBall.size.width / 2)
        botBall.physicsBody?.restitution = 0.5
        botBall.physicsBody?.linearDamping = 1.0
        botBall.physicsBody?.categoryBitMask = PhysicsCategory.botBall
        addChild(botBall)

        botAttemptCount += 1

        let playerRandomSpeedX = CGFloat.random(in: -3...3)
        let botRandomSpeedX = CGFloat.random(in: -3...3)

        // Player logic
        let shouldPlayerMiss = Int.random(in: 1...5) == 5 // 1 из 5 попыток промах

        if shouldPlayerMiss {
            playerBall.physicsBody?.applyImpulse(CGVector(dx: playerRandomSpeedX, dy: -5))
        } else {
            let dx = (coin.position.x - playerBall.position.x) * 0.03 + playerRandomSpeedX
            let dy = (coin.position.y - playerBall.position.y) * 0.02
            playerBall.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        }

        // Bot logic
        let shouldBotHit = Int.random(in: 1...3) == 3 // 1 из 3 попыток попадание

        if shouldBotHit {
            let dx = (coin.position.x - botBall.position.x) * 0.03 + botRandomSpeedX
            let dy = (coin.position.y - botBall.position.y) * 0.02
            botBall.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        } else {
            botBall.physicsBody?.applyImpulse(CGVector(dx: botRandomSpeedX, dy: -5))
        }
    }

    func toggleSettingsPanel() {
        isSettingsPanelVisible.toggle()
        if isSettingsPanelVisible {
            showSettingsPanel()
        } else {
            hideSettingsPanel()
        }
    }

    func showSettingsPanel() {
        settingsPanel = SKSpriteNode(color: .black, size: CGSize(width: size.width * 0.8, height: size.height * 0.3))
        settingsPanel.alpha = 0.5
        settingsPanel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(settingsPanel)

        homeButton = SKSpriteNode(imageNamed: "HomeButton")
        homeButton.position = CGPoint(x: settingsPanel.position.x - 60, y: settingsPanel.position.y)
        addChild(homeButton)

        restartButton = SKSpriteNode(imageNamed: "RestartButton")
        restartButton.position = CGPoint(x: settingsPanel.position.x, y: settingsPanel.position.y)
        addChild(restartButton)

        soundButton = SKSpriteNode(imageNamed: soundManager.isSoundOn ? "SoundOnButton" : "SoundOffButton")
        soundButton.position = CGPoint(x: settingsPanel.position.x + 60, y: settingsPanel.position.y)
        addChild(soundButton)
    }

    func hideSettingsPanel() {
        settingsPanel.removeFromParent()
        homeButton.removeFromParent()
        restartButton.removeFromParent()
        soundButton.removeFromParent()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if pauseButton.contains(location) {
            toggleSettingsPanel()
        } else if !isSettingsPanelVisible {
            launchBalls() // Запуск шаров по касанию
        }
    }

    var playerHitCoin = false
    var livesUpdated = false

    override func update(_ currentTime: TimeInterval) {
        if ballInPlay && playerBall.position.y < 0 && botBall.position.y < 0 {
            ballInPlay = false
            playerBall.removeFromParent()
            botBall.removeFromParent()

            if playerHitCoin {
                generateNewCoin()
            } else if !livesUpdated {
                playerLives -= 1
                updatePlayerLives()
                livesUpdated = true

                if playerLives <= 0 {
                    showGameOver()
                } else {
                    generateNewCoin()
                }
            }

            playerHitCoin = false
            livesUpdated = false
        }
    }

    func generateNewCoin() {
        coin?.removeFromParent()
        let randomIndex = Int.random(in: 0..<obstacles.count)
        let coinPosition = obstacles[randomIndex].position

        coin = SKSpriteNode(imageNamed: "coin-1")
        coin.position = coinPosition
        coin.setScale(0.15)
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.playerBall | PhysicsCategory.botBall
        addChild(coin)

        // Создаем массив текстур для анимации от 1 до 10
        var coinTextures: [SKTexture] = []
        for i in 1...10 {
            let textureName = "coin-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            coinTextures.append(texture)
        }

        // Создаем обратную последовательность от 9 до 1 (для 11-20)
        var reverseCoinTextures: [SKTexture] = []
        for i in (1...9).reversed() {
            let textureName = "coin-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            reverseCoinTextures.append(texture)
        }

        // Объединяем все текстуры
        let fullAnimationTextures = coinTextures + reverseCoinTextures

        // Создаем анимацию для первых 10 кадров
        let forwardAnimation = SKAction.animate(with: coinTextures, timePerFrame: 0.1)

        // Анимация с переворотом от 11 до 20
        let flippedAnimation = SKAction.run { [weak self] in
            self?.coin.xScale = -0.15 // Отражаем текстуры от 11 до 20
        }
        let reverseAnimation = SKAction.animate(with: reverseCoinTextures, timePerFrame: 0.1)

        // Возвращаем нормальный масштаб
        let unflippedAnimation = SKAction.run { [weak self] in
            self?.coin.xScale = 0.15 // Восстанавливаем обычный масштаб
        }

        // Создаем последовательность анимаций
        let sequence = SKAction.sequence([forwardAnimation, flippedAnimation, reverseAnimation, unflippedAnimation])

        // Запускаем бесконечную анимацию
        let repeatAnimation = SKAction.repeatForever(sequence)
        coin.run(repeatAnimation)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        // Check if player ball hits the coin
        if (firstBody.categoryBitMask == PhysicsCategory.playerBall && secondBody.categoryBitMask == PhysicsCategory.coin) ||
            (firstBody.categoryBitMask == PhysicsCategory.coin && secondBody.categoryBitMask == PhysicsCategory.playerBall) {
            playerScore += 1
            updateScore()
            playerHitCoin = true

            if secondBody.categoryBitMask == PhysicsCategory.coin {
                secondBody.node?.removeFromParent()
            } else if firstBody.categoryBitMask == PhysicsCategory.coin {
                firstBody.node?.removeFromParent()
            }
        }

        // Check if bot ball hits the coin
        if (firstBody.categoryBitMask == PhysicsCategory.botBall && secondBody.categoryBitMask == PhysicsCategory.coin) ||
            (firstBody.categoryBitMask == PhysicsCategory.coin && secondBody.categoryBitMask == PhysicsCategory.botBall) {
            botScore += 1
            updateBotScore()

            if secondBody.categoryBitMask == PhysicsCategory.coin {
                secondBody.node?.removeFromParent()
            } else if firstBody.categoryBitMask == PhysicsCategory.coin {
                firstBody.node?.removeFromParent()
            }
        }
    }

    func showGameOver() {
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverLabel.zPosition = 10
        addChild(gameOverLabel)
    }

    func updateBotScore() {
        botScoreLabel.text = "\(botScore)"
    }

    func updateScore() {
        playerScoreLabel.text = "\(playerScore)"
    }
}
