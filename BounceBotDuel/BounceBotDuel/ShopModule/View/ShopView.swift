//
//  ShopView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 13.10.24.
//

import SwiftUI

struct ShopView: View {
    // MARK: - Property -
    @EnvironmentObject var viewModel: ShopViewModel
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Coin Block -
    var coinBlock: some View {
        VStack {
            HStack {
                HStack {
                    Image(.coin)
                        .resizable()
                        .frame(width: 14, height: 14)
                    
                    Text("\(viewModel.coinCount)")
                        .font(.appBold(of: 13))
                        .foregroundColor(.cFFE500)
                        .padding(.vertical, 1)
                }
                .padding(.horizontal, 5)
            }
            .frame(width: 64, height: 21)
            .background(.c32005A)
            .cornerRadius(10)
            .padding(.top, 10)
        }
        .background(
            Image(.block7)
        )
    }
    
    // MARK: - Navigation Bar -
    var navigationBar: some View {
        HStack {
            ZStack(alignment: .center) {
                Image(.block3)
                
                Image(viewModel.playerAvatar)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(10)
                    .padding(.bottom, 3)
            }
            
            Text(viewModel.playerName)
                .font(.appBold(of: 13))
                .foregroundColor(.cF4F7EE)
                .padding(.trailing, 8)
                .offset(y: -15)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(.backButton)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Switch buttons -
    var switchButtons: some View {
        HStack {
            HStack {
                Button {
                    viewModel.isBallActive = true
                } label: {
                    Image(viewModel.isBallActive ? .ballActiveButton : .ballNoActiveButton)
                        .resizable()
                        .scaledToFit()
                }
                
                Spacer()
                
                Button {
                    viewModel.isBallActive = false
                } label: {
                    Image(viewModel.isBallActive ? .backgroundNoActiveButton : .backgroundActiveButton)
                        .resizable()
                        .scaledToFit()
                }
            }
            .padding(13)
        }
        .frame(maxWidth: .infinity)
        .background(.c32005A.opacity(0.54))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.c9B6FFB, lineWidth: 2)
        )
        .padding(.horizontal, 40)
        .padding(.top, 22)
    }
    
    // MARK: - Body -
    var body: some View {
        ZStack {
            Image(viewModel.selectedBackgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                GeometryReader { geometry in
                    VStack {
                        ZStack(alignment: .center) {
                            navigationBar
                            coinBlock
                        }
                        .padding(.top, geometry.safeAreaInsets.top + viewModel.topPadding)
                        
                        switchButtons
                        
                        Spacer()
                        
                        if viewModel.isBallActive {
                            ScrollView(showsIndicators: false) {
                                
                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)
                                    ],
                                    spacing: 16
                                ) {
                                    ForEach(viewModel.balls) { ball in
                                        BallShopView(viewModel: viewModel, ball: ball)
                                    }
                                }
                            }
                            .padding(.top, 32)
                            .padding(.horizontal, 40)
                            .padding(.bottom, UIScreen.main.bounds.width <= 667 ? geometry.safeAreaInsets.bottom + 32 : geometry.safeAreaInsets.bottom + 90)
                                
                        } else {
                            ScrollView(showsIndicators: false) {

                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)
                                    ],
                                    spacing: 16
                                ) {
                                    ForEach(viewModel.backgrounds) { background in
                                        BackgroundShopView(viewModel: viewModel, background: background)
                                    }
                                }
                            }
                            .padding(.top, 32)
                            .padding(.horizontal, 40)
                            .padding(.bottom, UIScreen.main.bounds.width <= 667 ? geometry.safeAreaInsets.bottom + 32 : geometry.safeAreaInsets.bottom + 90)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            viewModel.refreshCoinCount()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ShopView()
}
