//
//  LetterView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 21/01/2024.
//

import SwiftUI

struct LetterView: View {

    @State private var dragAmount = CGSize.zero

    var letter: String
    var index: UUID
    var maxWidth: CGFloat

    var onChanged: ((UUID, CGPoint) -> Void)?
    var onEnded: ((UUID, CGPoint) -> Void)?
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: maxWidth * 0.2)
                    .fill(Color.theme.accent)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                Text(letter)
                    .font(.custom("ChalkboardSE-Regular", size: dynamicFontSize()))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: maxWidth, height: maxWidth)
            .offset(dragAmount)
            .zIndex(dragAmount == .zero ? 0 : 1)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        self.dragAmount = value.translation
                        self.onChanged?(self.index, value.location)
                    }
                    .onEnded { value in
                        self.onEnded?(self.index, value.location)
                        self.dragAmount = .zero
                    }
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Draggable letter: \(letter)"))
        }
    
    private func dynamicFontSize() -> CGFloat {
            if horizontalSizeClass == .regular {
                // Larger font size for iPads
                return max(maxWidth * 0.8, 30)
            } else {
                // Default font size for iPhones
                return max(maxWidth * 0.6, 24)
            }
        }
}

struct LetterView_Previews: PreviewProvider {
    static var previews: some View {
        LetterView(letter: "t", index: UUID(),  maxWidth: 50)
    }
}
