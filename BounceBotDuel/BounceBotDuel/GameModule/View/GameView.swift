//
//  GameView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 11.10.24.
//

import SwiftUI

struct GameView: View {
    // MARK: - Property -
    @StateObject var viewModel = GameViewModel()
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Navigation Bar -
    var navigationBar: some View {
        HStack {
            ZStack {
                Image(.block6)
            }
            .blur(radius: viewModel.isSettingsPanelVisible ? 5 : 0)

            Spacer()

            ZStack(alignment: .trailing) {
                if viewModel.isSettingsPanelVisible {
                    HStack {
                        HStack(spacing: 8) {
                            Button {
                                dismiss()
                            } label: {
                                Image(.homeButton)
                            }

                            Button {
                                // Restart action
                            } label: {
                                Image(.restartButton)
                            }

                            Button {
                                soundManager.toggleSound()
                            } label: {
                                Image(soundManager.isSoundOn ? .soundOnButton : .soundOffButton)
                            }
                            .padding(.trailing, 50)
                        }
                        .padding(6)
                    }
                    .background(.c32005A.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.c9B6FFB, lineWidth: 4)
                    )
                    .cornerRadius(18)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isSettingsPanelVisible)
                }

                Button {
                    withAnimation {
                        viewModel.isSettingsPanelVisible.toggle()
                    }
                } label: {
                    Image(.pauseButton)
                }
                .offset(x: 10, y: 2)
            }
        }
        .padding(.horizontal, 24)
    }
    var scene: SKScene {
            let scene = GameScene()
            scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            scene.scaleMode = .resizeFill
            return scene
        }
    // MARK: - Body -
    var body: some View {
        ZStack {
            ZStack {
                Image(.background1)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                if viewModel.isSettingsPanelVisible {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                }
            }
            
            VStack {
                GeometryReader { geometry in

                    VStack {
                        navigationBar
                            .padding(.top, geometry.safeAreaInsets.top + viewModel.topPadding)
                        
                        HStack {
                            ZStack(alignment: .center) {
                                Image(.block3)
                                
                                Image(viewModel.playerAvatar)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(10)
                                    .padding(.bottom, 3)
                            }
                            
                            VStack {
                                Text(viewModel.playerName)
                                    .font(.appBold(of: 16))
                                    .foregroundColor(.cF4F7EE)
                                
                                Image(.life3)
                            }
                            .offset(y: -5)
                            .padding(.trailing, 8)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .blur(radius: viewModel.isSettingsPanelVisible ? 5 : 0)
                        
                        Spacer()
                        
                        SpriteView(scene: scene)

                        Spacer()
                    }
                        
                }
            }
            // Apply blur to everything except the settings panel

        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GameView()
        .environmentObject(SoundManager())
}

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var capsule: SKSpriteNode!
    var coin: SKSpriteNode!
    var playerBall: SKSpriteNode!
    var botBall: SKSpriteNode!
    var obstacles: [SKSpriteNode] = []
    var ballInPlay = false
    var playerScore = 0
    var playerScoreLabel: SKLabelNode!
    var background: SKSpriteNode!

    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let playerBall: UInt32 = 0b1
        static let botBall: UInt32 = 0b10
        static let coin: UInt32 = 0b100
    }

    override func didMove(to view: SKView) {
        background = SKSpriteNode(imageNamed: "Background1")
        background.size = self.size
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.zPosition = -1
        addChild(background)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        setupCapsule()
        setupCoin()
        setupObstacles()
        setupScoreLabel()
    }
    
    // Setup the capsule where balls will drop from
    func setupCapsule() {
        capsule = SKSpriteNode(imageNamed: "Pipe")
        capsule.position = CGPoint(x: size.width / 2, y: size.height - 50)
        capsule.physicsBody = SKPhysicsBody(rectangleOf: capsule.size)
        capsule.physicsBody?.isDynamic = false
        addChild(capsule)
    }
    
    // Setup the single coin
    func setupCoin() {
        coin = SKSpriteNode(imageNamed: "Coin")
        let randomX = CGFloat.random(in: 50...size.width - 50)
        coin.position = CGPoint(x: randomX, y: 100) // Place coin near the bottom
        coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.playerBall | PhysicsCategory.botBall
        addChild(coin)
    }
    
    // Setup the score label
    func setupScoreLabel() {
        playerScoreLabel = SKLabelNode(text: "Score: \(playerScore)")
        playerScoreLabel.fontSize = 24
        playerScoreLabel.fontColor = .white
        playerScoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(playerScoreLabel)
    }
    
    // Create obstacles in a grid pattern (like Plinko pegs)
    func setupObstacles() {
        let rows = 5
        let cols = 7
        let spacingX: CGFloat = size.width / CGFloat(cols + 1)
        let spacingY: CGFloat = size.height / CGFloat(rows + 3)
        
        for row in 0..<rows {
            for col in 0..<cols {
                let peg = SKSpriteNode(imageNamed: "Pin")
                peg.size = CGSize(width: 20, height: 20)
                let offsetX = (row % 2 == 0) ? spacingX / 2 : 0
                let positionX = spacingX * CGFloat(col) + offsetX + spacingX / 2
                let positionY = size.height - (spacingY * CGFloat(row + 2))
                
                peg.position = CGPoint(x: positionX, y: positionY)
                peg.physicsBody = SKPhysicsBody(circleOfRadius: peg.size.width / 2)
                peg.physicsBody?.isDynamic = false
                peg.physicsBody?.restitution = 0.8
                addChild(peg)
                obstacles.append(peg)
            }
        }
    }
    
    // Launch both player's and bot's balls from the same position
    func launchBalls() {
        guard !ballInPlay else { return }
        
        // Launch Player Ball
        playerBall = SKSpriteNode(imageNamed: "PlayerBall")
        playerBall.position = capsule.position
        playerBall.physicsBody = SKPhysicsBody(circleOfRadius: playerBall.size.width / 2)
        playerBall.physicsBody?.restitution = 0.5
        playerBall.physicsBody?.linearDamping = 0.3
        playerBall.physicsBody?.categoryBitMask = PhysicsCategory.playerBall
        playerBall.physicsBody?.contactTestBitMask = PhysicsCategory.coin
        addChild(playerBall)
        
        // Launch Bot Ball
        botBall = SKSpriteNode(imageNamed: "BotBall")
        botBall.position = capsule.position
        botBall.physicsBody = SKPhysicsBody(circleOfRadius: botBall.size.width / 2)
        botBall.physicsBody?.restitution = 0.5
        botBall.physicsBody?.linearDamping = 0.3
        botBall.physicsBody?.categoryBitMask = PhysicsCategory.botBall
        addChild(botBall)
        
        // Apply forces to both balls
        playerBall.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -10))
        botBall.physicsBody?.applyImpulse(CGVector(dx: CGFloat.random(in: -5...5), dy: -10))
        
        ballInPlay = true
    }
    
    // Handle touches to launch balls
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        launchBalls()
    }
    
    // Collision detection between balls and the coin
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == PhysicsCategory.playerBall && secondBody.categoryBitMask == PhysicsCategory.coin) ||
           (firstBody.categoryBitMask == PhysicsCategory.coin && secondBody.categoryBitMask == PhysicsCategory.playerBall) {
            playerScore += 1
            updateScore()
        }
    }
    
    // Update score display
    func updateScore() {
        playerScoreLabel.text = "Score: \(playerScore)"
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Check if both balls have fallen off the screen
        if ballInPlay && playerBall.position.y < 0 && botBall.position.y < 0 {
            ballInPlay = false
            playerBall.removeFromParent()
            botBall.removeFromParent()
            // Allow the player to launch balls again
        }
    }
}

