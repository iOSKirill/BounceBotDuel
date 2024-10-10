//
//  MenuView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 10.10.24.
//

import SwiftUI

struct MenuView: View {
    // MARK: - Property -
    @StateObject private var viewModel = MenuViewModel()
    @EnvironmentObject var soundManager: SoundManager
   
    // MARK: - Play button -
    var playButton: some View {
        NavigationLink(destination: EmptyView()) {
            Image(.playButton)
        }
        .padding(.top, 100)
    }
    
    // MARK: - Shop, Achievements and info buttons -
    var additionalButtons: some View {
        HStack(spacing: 0) {
            NavigationLink(destination: EmptyView()) {
                Image(.infoButton)
            }
            .offset(x: 25)
            
            NavigationLink(destination: EmptyView()) {
                Image(.achievementsButton)
            }
            .offset(y: -10)
            
            NavigationLink(destination: EmptyView()) {
                Image(.shopButton)
            }
            .offset(x: -25)
        }
        .padding(.bottom, 150)
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
                .font(.appBold(of: viewModel.isSettingsPanelVisible ? 10 : 16))
                .foregroundColor(.cF4F7EE)
                .padding(.trailing, 8)
                .offset(y: -15)
            
            Spacer()
            
            HStack {
          
                if viewModel.isSettingsPanelVisible {
                    HStack {
                        HStack(spacing: 8) {
                            Button {
                                soundManager.toggleSound()
                            } label: {
                                Image(soundManager.isSoundOn ? .soundOnButton : .soundOffButton)
                            }
                            
                            Button {
                                viewModel.rateUs()
                            } label: {
                                Image(.rateUsButton)
                            }
                            .padding(.trailing, 50)
                        }
                        .padding(6)
                    }
                    .background(.c32005A.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.c9B6FFB, lineWidth: 4)
                    )
                    .cornerRadius(18)
                    .offset(x: 55, y: -2)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isSettingsPanelVisible)
                }

                Button {
                    withAnimation {
                        viewModel.isSettingsPanelVisible.toggle()
                    }
                } label: {
                    Image(.settingsButton)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Body -
    var body: some View {
        NavigationView {
            
            ZStack {
                Image(.background1)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    GeometryReader { geometry in
                        VStack {
                            navigationBar
                                .padding(.top, geometry.safeAreaInsets.top + viewModel.topPadding)
                            
                            Spacer()
                            
                            playButton
                            
                            Spacer()
                            
                            additionalButtons
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MenuView()
}
