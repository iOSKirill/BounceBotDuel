//
//  GameViewModel.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 11.10.24.
//

import Foundation
import UIKit

class GameViewModel: ObservableObject {
    // MARK: - Property -
    @Published var isSettingsPanelVisible = false
    @Published var playerName: String = "Player"
    @Published var playerAvatar: String = "Avatar1"
    
    private let nameKey = "playerName"
    private let avatarKey = "selectedAvatar"
    
    var topPadding: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight <= 667 ? 100 : 60
    }
    
    // MARK: - Init -
    init() {
        loadUserData()
    }

    // Load Name and Avatar user
    func loadUserData() {
        playerName = UserDefaults.standard.string(forKey: nameKey) ?? "Player"
        playerAvatar = UserDefaults.standard.string(forKey: avatarKey) ?? "Avatar1"
    }
}
