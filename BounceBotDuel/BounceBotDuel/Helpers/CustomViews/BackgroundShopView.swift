//
//  BackgroundShopView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 13.10.24.
//

import SwiftUI

struct BackgroundShopView: View {
    // MARK: - Property -
    @ObservedObject var viewModel: ShopViewModel
    var background: Background
    
    // MARK: - Body -
    var body: some View {
        VStack {
            VStack {

                VStack {
                    // Display background image
                    Image(background.imageName)
                        .resizable()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(background.isSelected ? Color.c3BF52B : Color.cF52BBA, lineWidth: 4)
                )
                .cornerRadius(10)
                
                // Conditional HStack for buy, use, or lock
                if !background.isPurchased && viewModel.coinCount >= background.price {
                    HStack {
                        Button {
                            viewModel.purchaseBackground(background)
                        } label: {
                            Image(.buyButton)
                            Image(.coinBlock)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                } else if background.isPurchased && !background.isSelected {
                    HStack {
                        Button {
                            viewModel.selectBackground(background)
                        } label: {
                            Image(.useButton)
                        }
                        Image(.coinBlock)
                    }
                    .padding(.horizontal, 16)
                    
                } else if !background.isPurchased && viewModel.coinCount < background.price {
                    HStack {
                        Image(.lockButton)
                        Image(.coinBlock)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: 167, maxHeight: 167)
        .background(.c32005A.opacity(0.54))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.c9B6FFB, lineWidth: 5)
        )
        .cornerRadius(18)
    }
}
