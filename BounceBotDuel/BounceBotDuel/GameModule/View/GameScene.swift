//
//  GameScene.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 14.10.24.
//

import SpriteKit
import UIKit
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    @StateObject private var viewModel = GameViewModel()
    @ObservedObject private var shopViewModel: ShopViewModel

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
    var winBlock: SKSpriteNode?
    var loseBlock: SKSpriteNode?

    var collectedCoins = 0
    var playerLives = 3
    var lifeIndicator: SKSpriteNode!

    var winCallback: ((Int) -> Void)?
    var loseCallback: (() -> Void)?

    let coinKey = "totalCoins"
    
    var levelHomeButton: SKSpriteNode?
    var levelNextButton: SKSpriteNode?
    var levelRestartButton: SKSpriteNode?
    
    var blurBackground: SKEffectNode?
    var dimOverlay: SKSpriteNode?
    
    var dismissCallback: (() -> Void)?
    
    let maxLevel = 10
    var requiredCoinsForLevel = 1

    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let playerBall: UInt32 = 0b1  // 1
        static let botBall: UInt32 = 0b10    // 2
        static let coin: UInt32 = 0b100      // 4
        static let pin: UInt32 = 0b1000      // 8
    }


    let level1RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3), CGPoint(x: 2, y: 3),
        CGPoint(x: -1.5, y: 2.5), CGPoint(x: -0.5, y: 2.5), CGPoint(x: 0.5, y: 2.5), CGPoint(x: 1.5, y: 2.5),
        CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2), CGPoint(x: 2, y: 2),
        CGPoint(x: -1.5, y: 1.5), CGPoint(x: -0.5, y: 1.5), CGPoint(x: 0.5, y: 1.5), CGPoint(x: 1.5, y: 1.5),
        CGPoint(x: -2, y: 1), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1)
    ]
    
    let level2RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3), CGPoint(x: 2, y: 3),
        CGPoint(x: -1.5, y: 2.5), CGPoint(x: -0.5, y: 2.5), CGPoint(x: 0.5, y: 2.5), CGPoint(x: 1.5, y: 2.5),
        CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2),
        CGPoint(x: -1.5, y: 1.5), CGPoint(x: -0.5, y: 1.5), CGPoint(x: 0.5, y: 1.5), CGPoint(x: 1.5, y: 1.5)
    ]


    
    let level3RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3),
        CGPoint(x: -1.5, y: 2.5), CGPoint(x: -0.5, y: 2.5), CGPoint(x: 0.5, y: 2.5), CGPoint(x: 1.5, y: 2.5),
        CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2),
        CGPoint(x: -1.5, y: 1.5), CGPoint(x: -0.5, y: 1.5), CGPoint(x: 0.5, y: 1.5), CGPoint(x: 1.5, y: 1.5),
        CGPoint(x: -2, y: 1), CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1)
    ]

    
    let level4RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3), CGPoint(x: 2, y: 3),
        CGPoint(x: -1.5, y: 2.5), CGPoint(x: -0.5, y: 2.5), CGPoint(x: 0.5, y: 2.5), CGPoint(x: 1.5, y: 2.5),
        CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2),
        CGPoint(x: -1.5, y: 1.5), CGPoint(x: -0.5, y: 1.5), CGPoint(x: 0.5, y: 1.5),
        CGPoint(x: -1, y: 1), CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1)
    ]

    
    let level5RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3),
        CGPoint(x: -2, y: 2.5), CGPoint(x: -1, y: 2.5), CGPoint(x: 0, y: 2.5), CGPoint(x: 1, y: 2.5),
        CGPoint(x: -1.5, y: 2), CGPoint(x: -0.5, y: 2), CGPoint(x: 0.5, y: 2), CGPoint(x: 1.5, y: 2),
        CGPoint(x: -2, y: 1.5), CGPoint(x: -1, y: 1.5), CGPoint(x: 0, y: 1.5), CGPoint(x: 1, y: 1.5)
    ]

    
    let level6RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3),
        CGPoint(x: -1.5, y: 2.5), CGPoint(x: -0.5, y: 2.5), CGPoint(x: 0.5, y: 2.5),
        CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2),
        CGPoint(x: -1.5, y: 1.5), CGPoint(x: -0.5, y: 1.5), CGPoint(x: 0.5, y: 1.5), CGPoint(x: 1.5, y: 1.5)
    ]

    
    let level7RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3),
        CGPoint(x: -2, y: 2.5), CGPoint(x: -1, y: 2.5), CGPoint(x: 0, y: 2.5), CGPoint(x: 1, y: 2.5),
        CGPoint(x: -1.5, y: 2), CGPoint(x: -0.5, y: 2), CGPoint(x: 0.5, y: 2),
        CGPoint(x: -2, y: 1.5), CGPoint(x: -1, y: 1.5), CGPoint(x: 0, y: 1.5), CGPoint(x: 1, y: 1.5)
    ]

    
    let level8RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3),
        CGPoint(x: -2, y: 2.5), CGPoint(x: -1, y: 2.5), CGPoint(x: 0, y: 2.5),
        CGPoint(x: -1.5, y: 2), CGPoint(x: -0.5, y: 2), CGPoint(x: 0.5, y: 2),
        CGPoint(x: -2, y: 1.5), CGPoint(x: -1, y: 1.5), CGPoint(x: 0, y: 1.5),
        CGPoint(x: -1.5, y: 1), CGPoint(x: -0.5, y: 1), CGPoint(x: 0.5, y: 1)
    ]

    
    let level9RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3),
        CGPoint(x: -1.5, y: 2.5), CGPoint(x: -0.5, y: 2.5), CGPoint(x: 0.5, y: 2.5),
        CGPoint(x: -2, y: 2), CGPoint(x: -1, y: 2), CGPoint(x: 0, y: 2), CGPoint(x: 1, y: 2),
        CGPoint(x: -1.5, y: 1.5), CGPoint(x: -0.5, y: 1.5), CGPoint(x: 0.5, y: 1.5)
    ]


    
    let level10RelativePins: [CGPoint] = [
        CGPoint(x: -2, y: 3), CGPoint(x: -1, y: 3), CGPoint(x: 0, y: 3), CGPoint(x: 1, y: 3),
        CGPoint(x: -2, y: 2.5), CGPoint(x: -1, y: 2.5), CGPoint(x: 0, y: 2.5),
        CGPoint(x: -1.5, y: 2), CGPoint(x: -0.5, y: 2), CGPoint(x: 0.5, y: 2),
        CGPoint(x: -2, y: 1.5), CGPoint(x: -1, y: 1.5), CGPoint(x: 0, y: 1.5), CGPoint(x: 1, y: 1.5)
    ]



    init(soundManager: SoundManager, shopViewModel: ShopViewModel, winCallback: @escaping (Int) -> Void, loseCallback: @escaping () -> Void) {
        self.soundManager = soundManager
        self.shopViewModel = shopViewModel
        self.winCallback = winCallback
        self.loseCallback = loseCallback
        super.init(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentLevel = 1
    var requiredCoins = 1
    

    override func didMove(to view: SKView) {
        requiredCoins = 1
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
        setupLevel()
        setupWinLoseBlocks()
        setupBlurAndDim()
        setupSettingsPanel()
        setupDimmingLayer()
        physicsWorld.gravity = CGVector(dx: 0, dy: -4.8)
        physicsWorld.contactDelegate = self
    }
    
    func restartLevel() {
        resetGame()
        requiredCoins = currentLevel
    }

    func setupBlurAndDim() {
        blurBackground = SKEffectNode()
        let blurFilter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 20])
        blurBackground?.filter = blurFilter
        blurBackground?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        blurBackground?.zPosition = 9
        blurBackground?.isHidden = true
        addChild(blurBackground!)
        
        dimOverlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.75), size: self.size)
        dimOverlay?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dimOverlay?.zPosition = 9
        dimOverlay?.isHidden = true
        addChild(dimOverlay!)
    }

    func hideWinLoseBlocks() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.3) // Плавное исчезновение
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.3) // Уменьшение размера
        let group = SKAction.group([fadeOut, scaleDown]) // Одновременное выполнение

        winBlock?.run(group) {
            self.winBlock?.isHidden = true
            self.blurBackground?.isHidden = true
            self.dimOverlay?.isHidden = true
        }
        
        loseBlock?.run(group) {
            self.loseBlock?.isHidden = true
            self.blurBackground?.isHidden = true
            self.dimOverlay?.isHidden = true
        }
    }
    
    func setupWinLoseBlocks() {
        // Win Block
        winBlock = SKSpriteNode(imageNamed: "BlockWin")
        winBlock?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        winBlock?.zPosition = 10
        winBlock?.isHidden = true
        addChild(winBlock!)

        levelHomeButton = SKSpriteNode(imageNamed: "LevelHome")
        levelHomeButton?.position = CGPoint(x: -90, y: -100)
        levelHomeButton?.name = "levelHomeButton"
        levelHomeButton?.zPosition = 11
        winBlock?.addChild(levelHomeButton!)

        levelNextButton = SKSpriteNode(imageNamed: "LevelNext")
        levelNextButton?.position = CGPoint(x: 45, y: -100)
        levelNextButton?.name = "levelNextButton"
        levelNextButton?.zPosition = 11
        winBlock?.addChild(levelNextButton!)

        // Lose Block
        loseBlock = SKSpriteNode(imageNamed: "BLockLose")
        loseBlock?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        loseBlock?.zPosition = 10
        loseBlock?.isHidden = true
        addChild(loseBlock!)

        levelHomeButton = SKSpriteNode(imageNamed: "LevelHome")
        levelHomeButton?.position = CGPoint(x: -45, y: -100)
        levelHomeButton?.name = "levelHomeButton"
        levelHomeButton?.zPosition = 11
        loseBlock?.addChild(levelHomeButton!)

        levelRestartButton = SKSpriteNode(imageNamed: "LevelRestart")
        levelRestartButton?.position = CGPoint(x: 45, y: -100)
        levelRestartButton?.name = "levelRestartButton"
        levelRestartButton?.zPosition = 11
        loseBlock?.addChild(levelRestartButton!)
    }

    func showWinBlock(coins: Int) {
        blurBackground?.isHidden = false
        dimOverlay?.isHidden = false

        winBlock?.alpha = 0 // Изначально делаем блок полностью прозрачным
        winBlock?.setScale(0.5) // Уменьшаем масштаб блока для начальной анимации
        winBlock?.isHidden = false
        
        // Анимация увеличения и появления
        let fadeIn = SKAction.fadeIn(withDuration: 0.3) // Плавное появление
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3) // Увеличение до нормального размера
        let group = SKAction.group([fadeIn, scaleUp]) // Одновременное выполнение

        winBlock?.run(group)

        // Удаляем предыдущие динамические элементы (монеты и метки)
        winBlock?.children.forEach { node in
            if node.name == "coin" || node.name == "coinLabel" {
                node.removeFromParent()
            }
        }

        // Создаем метку с количеством монет
        let coinLabel = SKLabelNode(fontNamed: "SupercellMagic")
        coinLabel.text = "\(coins)"  // Выводим актуальное количество монет
        coinLabel.fontSize = 32
        coinLabel.fontColor = .cFFE500
        coinLabel.name = "coinLabel" // Присваиваем имя для будущего удаления
        winBlock?.addChild(coinLabel)

        // Создаем изображение монеты
        let coin = SKSpriteNode(imageNamed: "Coin")
        coin.setScale(1)
        coin.name = "coin" // Присваиваем имя для будущего удаления
        winBlock?.addChild(coin)

        // Рассчитываем общую ширину для правильного позиционирования
        let totalWidth = coin.size.width + coinLabel.frame.width + 10

        // Позиционируем монету и метку
        coin.position = CGPoint(x: -(totalWidth / 2) + coin.size.width / 2, y: -8)
        coinLabel.position = CGPoint(x: coin.position.x + coin.size.width / 2 + 10 + coinLabel.frame.width / 2, y: -20)
    }



    func showLoseBlock() {
        blurBackground?.isHidden = false
        dimOverlay?.isHidden = false

        loseBlock?.alpha = 0 // Изначально делаем блок полностью прозрачным
        loseBlock?.setScale(0.5) // Уменьшаем масштаб блока для начальной анимации
        loseBlock?.isHidden = false
        
        // Анимация увеличения и появления
        let fadeIn = SKAction.fadeIn(withDuration: 0.3) // Плавное появление
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3) // Увеличение до нормального размера
        let group = SKAction.group([fadeIn, scaleUp]) // Одновременное выполнение

        loseBlock?.run(group)

        let loseLabel = SKLabelNode(fontNamed: "SupercellMagic")
        loseLabel.text = "0"
        loseLabel.fontSize = 32
        loseLabel.fontColor = .cFFE500
        loseLabel.position = CGPoint(x: 0, y: -20)
        loseBlock?.addChild(loseLabel)
    }


    func setupBackground() {
         let selectedBackgroundImage = shopViewModel.selectedBackgroundImageName
         background = SKSpriteNode(imageNamed: selectedBackgroundImage)
         background.size = self.size
         background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
         background.zPosition = -1
         addChild(background)
     }
    
    func saveTotalCoins(_ coins: Int) {
        let currentCoins = UserDefaults.standard.integer(forKey: coinKey)
        UserDefaults.standard.set(currentCoins + coins, forKey: coinKey)
    }

    func setupPlayerNameLabel() {
        let avatarBackground = SKSpriteNode(imageNamed: "Block3")
        avatarBackground.size = CGSize(width: 60, height: 60)
        avatarBackground.position = CGPoint(x: 50, y: size.height < 760 ? size.height * 0.8 : size.height * 0.83)
        addChild(avatarBackground)
        
        let playerAvatarTexture = SKTexture(imageNamed: viewModel.playerAvatar)
        playerAvatar = SKSpriteNode(texture: playerAvatarTexture)
        playerAvatar.size = CGSize(width: 45, height: 45)
        playerAvatar.position = avatarBackground.position
        playerAvatar.zPosition = 1

        let roundedAvatar = SKShapeNode(rectOf: playerAvatar.size, cornerRadius: 10)
        roundedAvatar.fillTexture = playerAvatarTexture
        roundedAvatar.fillColor = .white
        roundedAvatar.position = CGPoint(x: playerAvatar.position.x, y: playerAvatar.position.y + 3)
        roundedAvatar.zPosition = 2
        addChild(roundedAvatar)
        
        playerNameLabel = SKLabelNode(fontNamed: "SupercellMagic")
        playerNameLabel.text = viewModel.playerName
        playerNameLabel.fontSize = 20
        playerNameLabel.fontColor = .white
        playerNameLabel.verticalAlignmentMode = .top
        playerNameLabel.zPosition = 2
        playerNameLabel.position = CGPoint(x: playerAvatar.position.x + 65, y: playerAvatar.position.y + playerAvatar.size.height / 2 + 3)
        addChild(playerNameLabel)
    }
    
    func setupScoreBoard() {
        scoreBoard = SKSpriteNode(imageNamed: "Block6")
        scoreBoard.position = CGPoint(x: 108, y: size.height * 0.9)
        scoreBoard.setScale(1.1)
        addChild(scoreBoard)
    }
    
    func setupScoreLabel() {
        let scoreCoinImage = SKSpriteNode(imageNamed: "Coin")
        scoreCoinImage.position = CGPoint(x: 55, y: size.height < 760 ? size.height * 0.892 : size.height * 0.895)
        scoreCoinImage.setScale(0.6)
        scoreCoinImage.zPosition = 2
        addChild(scoreCoinImage)
        
        playerScoreLabel = SKLabelNode(fontNamed: "SupercellMagic")
        playerScoreLabel.text = "\(playerScore)"
        playerScoreLabel.fontSize = 16
        playerScoreLabel.fontColor = .cFFE500
        playerScoreLabel.position = CGPoint(x: 75, y: size.height < 760 ? size.height * 0.884 :  size.height * 0.888)
        playerScoreLabel.zPosition = 2
        addChild(playerScoreLabel)
    }

    func setupBotScoreLabel() {
        botScoreLabel = SKLabelNode(fontNamed: "SupercellMagic")
        botScoreLabel.text = "\(botScore)"
        botScoreLabel.fontSize = 16
        botScoreLabel.fontColor = .c00D1FF
        botScoreLabel.position = CGPoint(x:150, y: size.height < 760 ? size.height * 0.884 : size.height * 0.888)
        addChild(botScoreLabel)
    }

    func setupPauseButton() {
        pauseButton = SKSpriteNode(imageNamed: "PauseButton")
        pauseButton.position = CGPoint(x: size.width - 50, y: size.height * 0.9)
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 4
        addChild(pauseButton)
    }
    
    var dimLayer: SKSpriteNode?

    func setupDimmingLayer() {
        // Create the dimming layer with semi-transparent black color
        dimLayer = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.75), size: size)
        dimLayer?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dimLayer?.zPosition = 2 // Ensure it's behind the settings panel
        dimLayer?.isHidden = true // Start hidden
        addChild(dimLayer!)
    }
    
    func toggleSound() {
        soundManager.toggleSound()
        let newSoundButtonImage = soundManager.isSoundOn ? "SoundOnButton" : "SoundOffButton"
        soundButton.texture = SKTexture(imageNamed: newSoundButtonImage)
    }

    func setupSettingsPanel() {
        // Create a background panel image (you can replace "BlockPause" with your actual image)
        settingsPanel = SKSpriteNode(imageNamed: "BlockPause")
        settingsPanel.size = CGSize(width: 190, height: 52) // Adjust size based on image
        settingsPanel.position = CGPoint(x: pauseButton.position.x - 80, y: pauseButton.position.y + 3) // Adjust position based on pause button
        settingsPanel.zPosition = 3 // Make sure it's behind the pause button
        settingsPanel.isHidden = true // Start hidden
        addChild(settingsPanel)

        // Create and add buttons
        let homeButton = SKSpriteNode(imageNamed: "HomeButton")
        homeButton.position = CGPoint(x: -68, y: 0)
        homeButton.name = "homeButton"
        settingsPanel.addChild(homeButton)

        let restartButton = SKSpriteNode(imageNamed: "RestartButton")
        restartButton.position = CGPoint(x: -19, y: 0)
        restartButton.name = "restartButton"
        settingsPanel.addChild(restartButton)

        let soundButton = SKSpriteNode(imageNamed: soundManager.isSoundOn ? "SoundOnButton" : "SoundOffButton")
        soundButton.position = CGPoint(x: 30, y: 0)
        soundButton.name = "soundButton"
        settingsPanel.addChild(soundButton)
    }

    func toggleSettingsPanel() {
        if isSettingsPanelVisible {
            // Hide the dim layer and settings panel
            dimLayer?.isHidden = true
            settingsPanel.isHidden = true
        } else {
            // Show the dim layer and settings panel
            dimLayer?.isHidden = false
            settingsPanel.isHidden = false
        }
        isSettingsPanelVisible.toggle()
    }

    func setupCapsule() {
        capsule = SKSpriteNode(imageNamed: "Pipe")
        capsule.position = CGPoint(x: size.width / 2, y: size.height / 1.5)
        addChild(capsule)
    }

    func generateLevelPins(relativePositions: [CGPoint], screenWidth: CGFloat, maxPinsInRow: Int) -> [CGPoint] {
        let pinSpacingX = screenWidth / CGFloat(maxPinsInRow + 0)
        let pinSpacingY = pinSpacingX * 1.2
        let centerX = screenWidth / 2
        let centerY = size.height < 760 ? size.height / 10 : size.height / 6
        
        print(size.height)

        return relativePositions.map { relativePos in
            let x = centerX + relativePos.x * pinSpacingX
            let y = centerY + relativePos.y * pinSpacingY
            return CGPoint(x: x, y: y)
        }
    }

    func setupObstaclesForLevel() {
        let screenWidth = self.size.width
        let maxPinsInRow = 5
        
        let levelPins: [CGPoint]
        
        // Switch based on the current level
        switch currentLevel {
        case 1:
            levelPins = generateLevelPins(relativePositions: level1RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
        case 2:
            levelPins = generateLevelPins(relativePositions: level2RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
        case 3:
            levelPins = generateLevelPins(relativePositions: level3RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
        case 4:
            levelPins = generateLevelPins(relativePositions: level4RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
            
        case 5:
            levelPins = generateLevelPins(relativePositions: level5RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
            
        case 6:
            levelPins = generateLevelPins(relativePositions: level6RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
            
        case 7:
            levelPins = generateLevelPins(relativePositions: level7RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
            
        case 8:
            levelPins = generateLevelPins(relativePositions: level8RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
            
        case 9:
            levelPins = generateLevelPins(relativePositions: level9RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
            
        case 10:
            levelPins = generateLevelPins(relativePositions: level10RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
        // Add more levels similarly
        default:
            levelPins = generateLevelPins(relativePositions: level1RelativePins, screenWidth: screenWidth, maxPinsInRow: maxPinsInRow)
        }
        
        // Clear existing obstacles
        obstacles.forEach { $0.removeFromParent() }
        obstacles.removeAll()
        
        for position in levelPins {
            let peg = SKSpriteNode(imageNamed: "Pin")
            peg.size = CGSize(width: 20, height: 28)
            peg.position = position
            peg.physicsBody = SKPhysicsBody(circleOfRadius: peg.size.width / 2)
            peg.physicsBody?.isDynamic = false
            peg.physicsBody?.restitution = 0.8
            peg.physicsBody?.categoryBitMask = PhysicsCategory.pin
            peg.physicsBody?.contactTestBitMask = PhysicsCategory.playerBall | PhysicsCategory.botBall
            addChild(peg)
            obstacles.append(peg)
        }
    }

    func setupLevel() {
        requiredCoinsForLevel = currentLevel
        resetGame()
    }
    
    
    func handleNextLevel() {
        if currentLevel < maxLevel {
            currentLevel += 1
            requiredCoinsForLevel = currentLevel
            setupLevel()
        } else {
            print("Поздравляем! Вы завершили все уровни.")
        }
    }


    func setupCoinForLevel() {
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

        var coinTextures: [SKTexture] = []
        for i in 1...10 {
            let textureName = "coin-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            coinTextures.append(texture)
        }

        var reverseCoinTextures: [SKTexture] = []
        for i in (1...9).reversed() {
            let textureName = "coin-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            reverseCoinTextures.append(texture)
        }

        let fullAnimationTextures = coinTextures + reverseCoinTextures
        let forwardAnimation = SKAction.animate(with: coinTextures, timePerFrame: 0.1)

        let flippedAnimation = SKAction.run { [weak self] in
            self?.coin.xScale = -0.15
        }
        let reverseAnimation = SKAction.animate(with: reverseCoinTextures, timePerFrame: 0.1)

        let unflippedAnimation = SKAction.run { [weak self] in
            self?.coin.xScale = 0.15
        }

        let sequence = SKAction.sequence([forwardAnimation, flippedAnimation, reverseAnimation, unflippedAnimation])

        let repeatAnimation = SKAction.repeatForever(sequence)
        coin.run(repeatAnimation)
    }


    func setupPlayerLives() {
        lifeIndicator = SKSpriteNode(imageNamed: "Life3")
        lifeIndicator.size = CGSize(width: 90, height: 10)
        lifeIndicator.position = CGPoint(x: playerNameLabel.position.x + 17, y: size.height < 760 ? size.height * 0.78 : size.height * 0.82)
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

        if playerLives <= 0 {
            showGameOver()
        }
    }

    func launchBalls() {
        guard !ballInPlay else { return }
        ballInPlay = true

        // Player Ball
        let selectedBallImage = shopViewModel.balls.first(where: { $0.isSelected })?.imageName ?? "Ball1"
        playerBall = SKSpriteNode(imageNamed: selectedBallImage)
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
        let shouldPlayerMiss = Int.random(in: 1...10) == 10

        if shouldPlayerMiss {
            playerBall.physicsBody?.applyImpulse(CGVector(dx: playerRandomSpeedX, dy: -5))
        } else {
            let dx = (coin.position.x - playerBall.position.x) * 0.03 + playerRandomSpeedX
            let dy = (coin.position.y - playerBall.position.y) * 0.03
            playerBall.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        }
        
        let shouldBotMiss = Int.random(in: 1...3) == 3

        if shouldBotMiss {
            let dx = (coin.position.x - playerBall.position.x) * 0.03 + botRandomSpeedX
            let dy = (coin.position.y - playerBall.position.y) * 0.02
            playerBall.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        } else {
            playerBall.physicsBody?.applyImpulse(CGVector(dx: botRandomSpeedX, dy: -5))
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
    
    
    func resetGame() {
        playerScore = 0
        botScore = 0
        collectedCoins = 0
        playerLives = 3
        ballInPlay = false

        playerScoreLabel.text = "\(playerScore)"
        botScoreLabel.text = "\(botScore)"
        updatePlayerLives()

        playerBall?.removeFromParent()
        botBall?.removeFromParent()
        coin?.removeFromParent()

        hideWinLoseBlocks()
        setupObstaclesForLevel()
        setupCoinForLevel()
        ballInPlay = false
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let node = atPoint(location) as? SKSpriteNode {
            if node == pauseButton {
                toggleSettingsPanel()
            } else if node.name == "homeButton" {
                dismissCallback?()
            } else if node.name == "restartButton" {
                resetGame()
                settingsPanel.isHidden = true
                dimLayer?.isHidden = true
                isSettingsPanelVisible.toggle()
            } else if node.name == "soundButton" {
                soundManager.toggleSound()
                let soundButton = node as! SKSpriteNode
                soundButton.texture = SKTexture(imageNamed: soundManager.isSoundOn ? "SoundOnButton" : "SoundOffButton")
            } else if  node.name == "levelHomeButton" {
                dismissCallback?()
            } else if node.name == "levelNextButton" {
                handleNextLevel()
            } else if node.name == "levelRestartButton" {
                restartLevel()
            } else {
                if !isSettingsPanelVisible {
                    launchBalls()
                }
            }
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

        var coinTextures: [SKTexture] = []
        for i in 1...10 {
            let textureName = "coin-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            coinTextures.append(texture)
        }

        var reverseCoinTextures: [SKTexture] = []
        for i in (1...9).reversed() {
            let textureName = "coin-\(i)"
            let texture = SKTexture(imageNamed: textureName)
            reverseCoinTextures.append(texture)
        }

        let fullAnimationTextures = coinTextures + reverseCoinTextures
        let forwardAnimation = SKAction.animate(with: coinTextures, timePerFrame: 0.1)

        let flippedAnimation = SKAction.run { [weak self] in
            self?.coin.xScale = -0.15
        }
        let reverseAnimation = SKAction.animate(with: reverseCoinTextures, timePerFrame: 0.1)

        let unflippedAnimation = SKAction.run { [weak self] in
            self?.coin.xScale = 0.15
        }

        let sequence = SKAction.sequence([forwardAnimation, flippedAnimation, reverseAnimation, unflippedAnimation])

        let repeatAnimation = SKAction.repeatForever(sequence)
        coin.run(repeatAnimation)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        if (firstBody.categoryBitMask == PhysicsCategory.playerBall && secondBody.categoryBitMask == PhysicsCategory.coin) ||
            (firstBody.categoryBitMask == PhysicsCategory.coin && secondBody.categoryBitMask == PhysicsCategory.playerBall) {
            playerScore += 1
            collectedCoins += 1
            updateScore()
            playerHitCoin = true
            playerCollectedCoin()

            let coinSoundAction = SKAction.playSoundFileNamed("coinSound.mp3", waitForCompletion: false)
            run(coinSoundAction)

            if collectedCoins >= 1 {
                showVictory()
            }

            if secondBody.categoryBitMask == PhysicsCategory.coin {
                secondBody.node?.removeFromParent()
            } else if firstBody.categoryBitMask == PhysicsCategory.coin {
                firstBody.node?.removeFromParent()
            }
        }

        if (firstBody.categoryBitMask == PhysicsCategory.playerBall && secondBody.categoryBitMask == PhysicsCategory.pin) ||
            (firstBody.categoryBitMask == PhysicsCategory.pin && secondBody.categoryBitMask == PhysicsCategory.playerBall) {
            let pinSoundAction = SKAction.playSoundFileNamed("pinSound.mp3", waitForCompletion: false)
            run(pinSoundAction)
        }

        if (firstBody.categoryBitMask == PhysicsCategory.botBall && secondBody.categoryBitMask == PhysicsCategory.pin) ||
            (firstBody.categoryBitMask == PhysicsCategory.pin && secondBody.categoryBitMask == PhysicsCategory.botBall) {
            let pinSoundAction = SKAction.playSoundFileNamed("pinSound.mp3", waitForCompletion: false)
            run(pinSoundAction)
        }

        if (firstBody.categoryBitMask == PhysicsCategory.botBall && secondBody.categoryBitMask == PhysicsCategory.coin) ||
            (firstBody.categoryBitMask == PhysicsCategory.coin && secondBody.categoryBitMask == PhysicsCategory.botBall) {
            botScore += 1
            updateBotScore()

            let coinSoundAction = SKAction.playSoundFileNamed("coinSound.mp3", waitForCompletion: false)
            run(coinSoundAction)

            if secondBody.categoryBitMask == PhysicsCategory.coin {
                secondBody.node?.removeFromParent()
            } else if firstBody.categoryBitMask == PhysicsCategory.coin {
                firstBody.node?.removeFromParent()
            }
        }
    }

    func showVictory() {
        // Проверяем, собрал ли игрок все необходимые монеты
        if collectedCoins >= requiredCoinsForLevel {
            // Вызов коллбека победы с количеством собранных монет
            winCallback?(collectedCoins)
            
            // Сохранение монет в UserDefaults
            saveTotalCoins(collectedCoins)
            
            // Отображаем экран победы
            showWinBlock(coins: collectedCoins)

            // Логика победы в матче
            playerWonMatch()

            // Переход на следующий уровень
            if currentLevel < maxLevel {
                currentLevel += 1
                requiredCoinsForLevel = currentLevel // Устанавливаем требуемое количество монет для нового уровня
            } else {
                print("Поздравляем! Все уровни завершены.")
            }

        }
    }

    func showGameOver() {
        loseCallback?()
        showLoseBlock()
    }

    func updateBotScore() {
        botScoreLabel.text = "\(botScore)"
    }

    func updateScore() {
        playerScoreLabel.text = "\(playerScore)"
    }
    
    func playerCollectedCoin() {
        updateScore()
        
        // Check if the player has collected their first coin
        if collectedCoins == 1 {
            shopViewModel.completeAchievement(shopViewModel.achievements.first { $0.id == "first_coin" }!)
            // Добавляем 15 монет за выполнение ачивки
            saveTotalCoins(15)
        }

        // If the required number of coins for the level is collected, show the victory
        if collectedCoins >= requiredCoinsForLevel {
            showVictory()
        }
    }
    
    func playerWonMatch() {
        // This logic will be called when the player wins the match
        shopViewModel.completeAchievement(shopViewModel.achievements.first { $0.id == "first_win" }!)
        // Добавляем 15 монет за выполнение ачивки
        saveTotalCoins(15)
    }
    
    func playerCoin() {

        updateScore()
        
        // Check if the player has collected 5 coins in one game
        if collectedCoins == 5 {
            shopViewModel.completeAchievement(shopViewModel.achievements.first { $0.id == "collect_5_coins" }!)
        }

        // If the required number of coins for the level is collected, show the victory
        if collectedCoins >= requiredCoinsForLevel {
            showVictory()
        }
    }

    var botWins = 0 // Add this to track bot wins

    func playerWonMatch10() {
        botWins += 1
        
        // Check if the player has defeated the bot 10 times
        if botWins == 10 {
            shopViewModel.completeAchievement(shopViewModel.achievements.first { $0.id == "win_10" }!)
        }
    }
    
    func playerWonMatch50() {
        botWins += 1
        
        // Check if the player has defeated the bot 50 times
        if botWins == 50 {
            shopViewModel.completeAchievement(shopViewModel.achievements.first { $0.id == "win_50" }!)
        }
    }
}
