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
    var level = 1
    var botScore = 0
    var botScoreLabel: SKLabelNode!
    var botAttemptCount = 0
    
    var playerLives = 3
    var lifeIndicator: SKSpriteNode! // Теперь только один индикатор жизни
    
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
        setupBotScoreLabel()
        setupPlayerNameLabel()
        setupPauseButton()
        setupPlayerLives()  // Инициализация одного индикатора жизни
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
        capsule.position = CGPoint(x: size.width / 2, y: size.height / 1.4)
        addChild(capsule)
    }

    // Преобразование относительных координат пинов в абсолютные с учетом размера экрана
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

    // Setup obstacles (pins) для текущего уровня
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

    // Setup coin для текущего уровня
    func setupCoinForLevel() {
        let randomIndex = Int.random(in: 0..<obstacles.count)
        let coinPosition = obstacles[randomIndex].position

        coin = SKSpriteNode(imageNamed: "Coin")
        coin.position = coinPosition
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.playerBall | PhysicsCategory.botBall
        addChild(coin)
    }

    // Setup Player Lives
    func setupPlayerLives() {
        lifeIndicator = SKSpriteNode(imageNamed: "Life3") // Начинаем с полной жизнью (зеленая)
        lifeIndicator.size = CGSize(width: 70, height: 20)
        lifeIndicator.position = CGPoint(x: size.width * 0.1, y: size.height - 80)
        addChild(lifeIndicator)
    }

    // Обновление текстуры индикатора жизней в зависимости от оставшихся жизней
    func updatePlayerLives() {
        if playerLives == 3 {
            lifeIndicator.texture = SKTexture(imageNamed: "Life3")
        } else if playerLives == 2 {
            lifeIndicator.texture = SKTexture(imageNamed: "Life2")
        } else if playerLives == 1 {
            lifeIndicator.texture = SKTexture(imageNamed: "Life1")
        } else {
            lifeIndicator.texture = SKTexture(imageNamed: "EmptyLife") // Пустая жизнь, игрок проиграл
        }
    }

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

        botAttemptCount += 1

        let playerRandomSpeedX = CGFloat.random(in: -3...3)
        let botRandomSpeedX = CGFloat.random(in: -3...3)

        // Логика для игрока
        let shouldPlayerMiss = Int.random(in: 1...5) == 5 // Промах в 1 из 5 попыток

        if shouldPlayerMiss {
            playerBall.physicsBody?.applyImpulse(CGVector(dx: playerRandomSpeedX, dy: -5))
            playerLives -= 1
       
        } else {
            let dx = (coin.position.x - playerBall.position.x) * 0.03 + playerRandomSpeedX
            let dy = (coin.position.y - playerBall.position.y) * 0.02
            playerBall.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        }

        let shouldBotHit = Int.random(in: 1...3) == 3

        if shouldBotHit {
            let dx = (coin.position.x - botBall.position.x) * 0.03 + botRandomSpeedX
            let dy = (coin.position.y - botBall.position.y) * 0.02
            botBall.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        } else {
            botBall.physicsBody?.applyImpulse(CGVector(dx: botRandomSpeedX, dy: -5))
        }

        ballInPlay = true
    }

    func gameOver() {
        print("Game Over! Player has no lives left.")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if pauseButton.contains(location) {
            toggleSettingsPanel()
        } else if !isSettingsPanelVisible {
            launchBalls()
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

    var playerHitCoin = false // Переменная для отслеживания попадания игрока

    override func update(_ currentTime: TimeInterval) {
        // Проверяем, упали ли оба шара
        if ballInPlay && playerBall.position.y < 0 && botBall.position.y < 0 {
            ballInPlay = false

            // Убираем шары с экрана
            playerBall.removeFromParent()
            botBall.removeFromParent()

            // Если игрок попал в монету
            if playerHitCoin {
                // Игрок попал, продолжаем игру
                generateNewCoin()
                playerHitCoin = false // Сброс флага
            } else {
                // Игрок промахнулся, уменьшаем жизни
                playerLives -= 1
                updatePlayerLives()

                if playerLives <= 0 {
                    // Отображаем текст Game Over
                    showGameOver()
                } else {
                    // Генерируем новую монету для следующего раунда
                    generateNewCoin()
                }
            }
        }
    }


    func generateNewCoin() {
        coin?.removeFromParent()
        let randomIndex = Int.random(in: 0..<obstacles.count)
        let coinPosition = obstacles[randomIndex].position

        coin = SKSpriteNode(imageNamed: "Coin")
        coin.position = coinPosition
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.playerBall | PhysicsCategory.botBall
        addChild(coin)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        // Проверка на контакт шара игрока с монетой
        if (firstBody.categoryBitMask == PhysicsCategory.playerBall && secondBody.categoryBitMask == PhysicsCategory.coin) ||
            (firstBody.categoryBitMask == PhysicsCategory.coin && secondBody.categoryBitMask == PhysicsCategory.playerBall) {
            playerScore += 1
            updateScore()

            playerHitCoin = true // Игрок попал в монету

            if secondBody.categoryBitMask == PhysicsCategory.coin {
                secondBody.node?.removeFromParent()
            } else if firstBody.categoryBitMask == PhysicsCategory.coin {
                firstBody.node?.removeFromParent()
            }
        }

        // Проверка на контакт шара бота с монетой
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
        gameOverLabel.zPosition = 10 // Поверх остальных элементов
        addChild(gameOverLabel)
    }

    func updateBotScore() {
        botScoreLabel.text = "Bot Score: \(botScore)"
    }

    func updateScore() {
        playerScoreLabel.text = "Score: \(playerScore)"
    }
}



