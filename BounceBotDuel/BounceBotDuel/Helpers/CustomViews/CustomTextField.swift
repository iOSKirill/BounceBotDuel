//
//  CustomTextField.swift
//  BounceBotDuel
//
//  Created by Kirill Manuilenko on 9.10.24.
//

import SwiftUI

struct CustomTextField: View {
    // MARK: - Property -
    @Binding var text: String

    // MARK: - Body -
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.cEE86FF)
                .frame(height: 50)

            TextField("Player", text: $text)
                .font(.appBold(of: 18))
                .foregroundColor(.c7C0070)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding(.horizontal, 20)
    }
}
