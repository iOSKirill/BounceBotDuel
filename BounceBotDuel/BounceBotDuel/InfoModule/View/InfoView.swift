//
//  InfoView.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 10.10.24.
//

import SwiftUI

struct InfoView: View {
    // MARK: - Property -
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var background: ShopViewModel
    
    // MARK: - Body -
    var body: some View {
        ZStack {
            Image(background.selectedBackgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(.block4)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(.nextButton)
                }
                .padding(.bottom, 90)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    InfoView()
}
