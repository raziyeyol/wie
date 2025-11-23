//
//  CustomButtonStyle.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 03/10/2024.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color.theme.iconColor
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 10
    var fontSize: CGFloat = 22
    var fontName: String = "ChalkboardSE-Regular"
    var width: CGFloat = 200
    var height: CGFloat = 50

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom(fontName, size: fontSize))
            .fontWeight(.bold)
            .foregroundColor(foregroundColor)
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
