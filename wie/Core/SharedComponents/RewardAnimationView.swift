//
//  RewardAnimationView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 19/09/2024.
//

import SwiftUI

struct RewardAnimationView: View {
    @State private var animate = false
    var animationDuration: Double = 1.0
    var image: Image = Image(systemName: "star.fill")
    var imageSize: CGSize = CGSize(width: 250, height: 250)
    var imageColor: Color = .yellow

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(imageColor)
            .frame(width: imageSize.width, height: imageSize.height)
            .scaleEffect(animate ? 1.5 : 1.0)
            .opacity(animate ? 0.0 : 1.0)
            .onAppear {
                withAnimation(.easeOut(duration: animationDuration)) {
                    animate = true
                }
            }
    }
}

#Preview {
    RewardAnimationView()
}
