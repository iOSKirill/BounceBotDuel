//
//  MenuViewModel.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 10.10.24.
//

import SwiftUI
import StoreKit

class MenuViewModel: ObservableObject {
    // MARK: - Property -
    @Published var playerName: String = "Player"
    @Published var playerAvatar: String = "Avatar1"
    
    @Published var isSettingsPanelVisible = false

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
    
    func rateUs() {
        if let scene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == .foregroundActive
        }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
