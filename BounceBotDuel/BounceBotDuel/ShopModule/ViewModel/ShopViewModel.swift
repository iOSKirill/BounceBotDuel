//
//  ShopViewModel.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 13.10.24.
//

import Foundation
import Combine
import UIKit

class ShopViewModel: ObservableObject {
    // MARK: - Properties -
    @Published var playerName: String = "Player"
    @Published var playerAvatar: String = "Avatar1"
    @Published var coinCount: Int = 0
    @Published var balls: [Ball] = []
    @Published var backgrounds: [Background] = []
    @Published var isSettingsPanelVisible = false
    @Published var isBallActive = true
    @Published var selectedBackgroundImageName: String = "Background1" // Default background

    private let nameKey = "playerName"
    private let avatarKey = "selectedAvatar"
    private let coinKey = "totalCoins"
    private let purchasedBallsKey = "purchasedBalls"
    private let selectedBallKey = "selectedBall"
    private let purchasedBackgroundsKey = "purchasedBackgrounds"
    private let selectedBackgroundKey = "selectedBackground"

    var topPadding: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight <= 667 ? 100 : 60
    }
    
    // MARK: - Init -
    init() {
        loadUserData()
        loadCoinCount()  // Загружаем счет при инициализации
        loadBallData()
        loadBackgroundData() // Load backgrounds
    }

    // Load Name and Avatar from UserDefaults
    func loadUserData() {
        playerName = UserDefaults.standard.string(forKey: nameKey) ?? "Player"
        playerAvatar = UserDefaults.standard.string(forKey: avatarKey) ?? "Avatar1"
    }
    
    // Load coin count from UserDefaults
    func loadCoinCount() {
        coinCount = UserDefaults.standard.integer(forKey: coinKey)
    }
    
    // Save coin count to UserDefaults
    func updateCoinCount(_ newCount: Int) {
        coinCount = newCount
        saveCoinCount()
    }

    // Save coin count to UserDefaults
    private func saveCoinCount() {
        UserDefaults.standard.set(coinCount, forKey: coinKey)
    }

    // Функция для обновления данных о монетах при каждом появлении экрана
    func refreshCoinCount() {
        loadCoinCount() // Обновляем счет из UserDefaults
    }
    
    // MARK: - Ball Data Management -
    func loadBallData() {
        for i in 1...10 {
            let isPurchased = UserDefaults.standard.bool(forKey: "\(purchasedBallsKey)_\(i)")
            let isSelected = UserDefaults.standard.integer(forKey: selectedBallKey) == i
            
            // Set first ball as purchased and selected by default
            if i == 1 && !isPurchased {
                UserDefaults.standard.set(true, forKey: "\(purchasedBallsKey)_1")
                UserDefaults.standard.set(1, forKey: selectedBallKey)
            }
            
            balls.append(Ball(id: i, imageName: "Ball\(i)", isPurchased: isPurchased, isSelected: isSelected))
        }
    }

    // Purchase a ball and update coin count
    func purchaseBall(_ ball: Ball) {
        guard let index = balls.firstIndex(where: { $0.id == ball.id }) else { return }
        
        if coinCount >= ball.price {
            coinCount -= ball.price
            balls[index].isPurchased = true
            savePurchasedState(ball.id)
            saveCoinCount()
        }
    }

    // Select a ball (deselect others)
    func selectBall(_ ball: Ball) {
        for i in 0..<balls.count {
            balls[i].isSelected = false
        }
        
        guard let index = balls.firstIndex(where: { $0.id == ball.id }) else { return }
        balls[index].isSelected = true
        saveSelectedBall(ball.id)
    }

    // Save purchased state to UserDefaults
    private func savePurchasedState(_ ballId: Int) {
        UserDefaults.standard.set(true, forKey: "\(purchasedBallsKey)_\(ballId)")
    }

    // Save selected ball ID to UserDefaults
    private func saveSelectedBall(_ ballId: Int) {
        UserDefaults.standard.set(ballId, forKey: selectedBallKey)
    }
    
    // MARK: - Background Data Management -
    func loadBackgroundData() {
        let selectedBackgroundId = UserDefaults.standard.integer(forKey: selectedBackgroundKey)
        for i in 1...10 {
            let isPurchased = UserDefaults.standard.bool(forKey: "\(purchasedBackgroundsKey)_\(i)")
            let isSelected = selectedBackgroundId == i
            
            // Set first background as purchased and selected by default
            if i == 1 && !isPurchased {
                UserDefaults.standard.set(true, forKey: "\(purchasedBackgroundsKey)_1")
                UserDefaults.standard.set(1, forKey: selectedBackgroundKey)
            }
            
            backgrounds.append(Background(id: i, imageName: "Background\(i)", isPurchased: isPurchased, isSelected: isSelected))
        }

        // Update the selected background image based on the UserDefaults value
        updateSelectedBackgroundImage()
    }

    // Purchase a background and update coin count
    func purchaseBackground(_ background: Background) {
        guard let index = backgrounds.firstIndex(where: { $0.id == background.id }) else { return }
        
        if coinCount >= background.price {
            coinCount -= background.price
            backgrounds[index].isPurchased = true
            savePurchasedBackgroundState(background.id)
            saveCoinCount()
        }
    }

    // Select a background (deselect others)
    func selectBackground(_ background: Background) {
        for i in 0..<backgrounds.count {
            backgrounds[i].isSelected = false
        }
        
        guard let index = backgrounds.firstIndex(where: { $0.id == background.id }) else { return }
        backgrounds[index].isSelected = true
        saveSelectedBackground(background.id)
        
        // Update the background image name
        updateSelectedBackgroundImage()
    }

    // Save purchased background state to UserDefaults
    private func savePurchasedBackgroundState(_ backgroundId: Int) {
        UserDefaults.standard.set(true, forKey: "\(purchasedBackgroundsKey)_\(backgroundId)")
    }

    // Save selected background ID to UserDefaults
    private func saveSelectedBackground(_ backgroundId: Int) {
        UserDefaults.standard.set(backgroundId, forKey: selectedBackgroundKey)
    }

    // Update the selected background image based on the current selection
    private func updateSelectedBackgroundImage() {
        if let selectedBackground = backgrounds.first(where: { $0.isSelected }) {
            selectedBackgroundImageName = selectedBackground.imageName
        } else {
            selectedBackgroundImageName = "Background1" // Fallback to default background
        }
    }
}

