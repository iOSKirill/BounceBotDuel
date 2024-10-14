//
//  BackgroundModel.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 13.10.24.
//

import Foundation

struct Background: Identifiable {
    var id: Int
    var imageName: String
    var isPurchased: Bool
    var isSelected: Bool
    var price: Int = 15 // Цена фона
}
