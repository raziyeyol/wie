//
//  CircularProgressView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 06/11/2024.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double // From 0.0 to 1.0
    var lineWidth: CGFloat = 6
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.3),
                    style: StrokeStyle(lineWidth: lineWidth)
                )
                .frame(width: size, height: size)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    Color.theme.iconColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: size, height: size)
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.28))
                .foregroundColor(Color.theme.accent)
                .bold()
        }
    }
}

