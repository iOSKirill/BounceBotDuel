//
//  ChoicePlayerViewModel.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 9.10.24.
//

import Foundation

class ChoicePlayerViewModel: ObservableObject {
    // MARK: - Property -
    private let avatarKey = "selectedAvatar"
    private let nameKey = "playerName"
    
    @Published var selectedAvatar: String = UserDefaults.standard.string(forKey: "selectedAvatar") ?? "avatar1"
    @Published var playerName: String = UserDefaults.standard.string(forKey: "playerName") ?? "Player"
    
    @Published var showNextScreen = false
    
    // Save image and name user
    func saveUserData() {
        UserDefaults.standard.set(selectedAvatar, forKey: avatarKey)
        UserDefaults.standard.set(playerName, forKey: nameKey)
    }
    
    // Load image and name user
    func loadUserData() {
        selectedAvatar = UserDefaults.standard.string(forKey: avatarKey) ?? "Avatar1"
        playerName = UserDefaults.standard.string(forKey: nameKey) ?? "Player"
    }
}
