//
//  LaunchView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 9.10.24.
//

import SwiftUI

struct LaunchView: View {
    // MARK: - Property -
    @StateObject private var viewModel = LaunchViewModel()
    
    // MARK: - Body -
    var body: some View {
        ZStack {
            Image(.background1)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(.launchText)
                    .scaleEffect(viewModel.isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: viewModel.isAnimating)
                    .onAppear {
                        viewModel.startAnimation()
                    }
                
                Spacer()
            }
            .fullScreenCover(isPresented: $viewModel.showNextScreen) {
                EmptyView()  
            }
        }
    }
}

#Preview {
    LaunchView()
}
