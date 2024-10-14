//
//  BallModel.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 13.10.24.
//

import Foundation

struct Ball: Identifiable {
    let id: Int
    let imageName: String
    var isPurchased: Bool
    var isSelected: Bool
    let price: Int = 15
}
