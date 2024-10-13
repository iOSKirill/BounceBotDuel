//
//  BallShopView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 13.10.24.
//

import SwiftUI

struct BallShopView: View {
    // MARK: - Property -
    @ObservedObject var viewModel: ShopViewModel
    var ball: Ball
    
    // MARK: - Body -
    var body: some View {
        VStack {
            VStack {
                VStack {
                    // Display ball image
                    Image(ball.imageName)
                        .resizable()
                        .frame(width: 70, height: 70)
                        .padding(16)
                        .padding(.horizontal, ball.isSelected ? 10 : 16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(ball.isSelected ? Color.c3BF52B : Color.cF52BBA, lineWidth: 4)
                )
                .cornerRadius(10)
                
                
                // Conditional HStack for buy, use, or lock
                if !ball.isPurchased && viewModel.coinCount >= ball.price {
                    HStack {
                        Button {
                            viewModel.purchaseBall(ball)
                        } label: {
                            Image(.buyButton)

                            Image(.coinBlock)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                } else if ball.isPurchased && !ball.isSelected {
                    HStack {
                        Button {
                            viewModel.selectBall(ball)
                        } label: {
                            Image(.useButton)
                        }
                        Image(.coinBlock)
                    }
                    .padding(.horizontal, 16)
                    
                } else if !ball.isPurchased && viewModel.coinCount < ball.price {
                    HStack {
                        Image(.lockButton)

                        Image(.coinBlock)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: 167, maxHeight: .infinity)
        .background(.c32005A.opacity(0.54))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.c9B6FFB, lineWidth: 5)
        )
        .cornerRadius(18)
    }
}

