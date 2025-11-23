//
//  Card.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 23/04/2024.
//

import SwiftUI

enum Status {
    case correct
    case wrong
    case empty
}

struct CardView: View {
    
    var word: String
    var maxWidth: CGFloat?
    var backgorundColor: Color?
    var status: Status
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgorundColor ?? Color.white)
                    .overlay(
                        Group {
                            switch status {
                            case .correct:
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .padding(10)
                            case .wrong:
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .padding(10)
                            case .empty:
                                EmptyView()
                            }
                        },
                        alignment: .topTrailing
                    )
                
                Text(word)
                    .font(.custom("ChalkboardSE-Regular", size: horizontalSizeClass == .regular ? 35 : 28))
                    .lineLimit(1)
                    .foregroundColor((backgorundColor != nil) ? .white : .black)
                    .multilineTextAlignment(.center)
            }
        .frame(maxWidth: maxWidth)
    }
}

#Preview {
    CardView(word: "pronunciation", maxWidth: 200, backgorundColor: nil, status: .empty)
}


#Preview {
    CardView(word: "Hello", maxWidth: 100, status: Status.empty)
}
