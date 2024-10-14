//
//  AchievementsView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 14.10.24.
//

import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let name: String
    let image: Image
    var isCompleted: Bool
}

extension UserDefaults {
    private var achievementsKey: String { "completedAchievements" }
    
    var completedAchievements: [String] {
        get { UserDefaults.standard.array(forKey: achievementsKey) as? [String] ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: achievementsKey) }
    }
}

struct AchievementsView: View {
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
                        
                        ScrollView(showsIndicators: false) {
                            ForEach(viewModel.achievements) { achievement in
                                ZStack {
                                    achievement.image
                                        .padding(2)  // Добавляем отступы внутри ободка
                                        .background(
                                            RoundedRectangle(cornerRadius: 21)
                                                .stroke(achievement.isCompleted ? Color.green : Color.clear, lineWidth: 10)
                                        )
                                        .cornerRadius(21)
                                }
                             
                            }
                            .padding(.bottom, 32)
                        }
                        .padding(.top, 52)
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            viewModel.refreshAchievements()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    AchievementsView()
        .environmentObject(ShopViewModel())
}
