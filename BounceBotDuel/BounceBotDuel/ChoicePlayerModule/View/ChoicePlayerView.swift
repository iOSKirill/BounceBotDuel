//
//  ChoicePlayerView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 9.10.24.
//

import SwiftUI

struct ChoicePlayerView: View {
    // MARK: - Property -
    @StateObject private var viewModel = ChoicePlayerViewModel()
    let avatars = ["Avatar1", "Avatar2", "Avatar3"]
    
    // MARK: - Block choose name and avatar player -
    var blockChooseNameAndAvatar: some View {
        ZStack(alignment: .top) {
            Image(.block2)
        
            VStack {
                
                VStack {
                    Image(viewModel.selectedAvatar)
                        .resizable()
                        .frame(width: 88, height: 88)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.c05FF00, lineWidth: 2)
                        )
                    Image(.enterYourNameText)
                        .padding(.top, 5)
                    
                    CustomTextField(text: $viewModel.playerName)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .padding(.top, 10)
                        .padding(.horizontal, 90)
                }
                .background(
                    Image(.block1)
                        .resizable()
                        .frame(width: 252, height: 205)
                )
                .padding(.top, 40)
                
                Image(.chooseAvatarText)
                    .padding(.top, 30)

                HStack(spacing: 18) {
                    ForEach(avatars, id: \.self) { avatar in
                        Image(avatar)
                            .resizable()
                            .frame(width: 70, height: 70)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(viewModel.selectedAvatar == avatar ? .c05FF00 : .cF4F7EE, lineWidth: 2)
                            )
                            .onTapGesture {
                                viewModel.selectedAvatar = avatar
                            }
                    }
                }
                .padding(.top, 10)
            }
        }
    }
    
    // MARK: - Button Go -
    var goButton: some View {
        Button {
            viewModel.saveUserData()
        } label: {
            Image(.goButton)
        }
        .padding(.bottom, 90)
    }
    
    // MARK: - Body -
    var body: some View {
        ZStack {
            Image(.background1)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        
            VStack {
                Spacer()
                
                blockChooseNameAndAvatar
                
                Spacer()
                
                goButton
            }
        }
        .onAppear {
            viewModel.loadUserData() 
        }
    }
}

#Preview {
    ChoicePlayerView()
}
