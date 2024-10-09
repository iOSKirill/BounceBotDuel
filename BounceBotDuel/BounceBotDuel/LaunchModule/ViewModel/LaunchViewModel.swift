//
//  LaunchViewModel.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 9.10.24.
//

import SwiftUI

class LaunchViewModel: ObservableObject {
    // MARK: - Property -
    @Published var isAnimating = false
    @Published var showNextScreen = false
    
    // Start animation text
    func startAnimation() {
        isAnimating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showNextScreen = true
        }
    }
}
