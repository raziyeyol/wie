//
//  Word.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 15/01/2024.
//

import SwiftUI

enum DragState {
    case unknown
    case good
    case bad
    
}

struct WordView: View {
    
    @State private var dragAmount = CGSize.zero
    @State private var dragState  = DragState.unknown
    
    var word: String
    var index : Int
    
    var onChanged: ((CGPoint, String) -> DragState)?
    var onEnded: ((CGPoint, Int, String) -> Void)?
    
    var body: some View {
        Text(word)
            .padding(.all, 10)
            .font(.title2)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.theme.iconColor))
            .foregroundColor(.white)
            .offset(dragAmount)
            .zIndex(dragAmount == .zero ? 0 : 1)
            //.shadow(color: dragColor, radius: dragAmount == .zero ? 0 : 10)
            //.shadow(color: dragColor, radius: dragAmount == .zero ? 0 : 10)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged {
                        self.dragAmount = CGSize(width:
                                                    $0.translation.width,height:
                                                    $0.translation.height)
                        self.dragState = self.onChanged?($0.location, self.word) ?? .unknown
                    }
                    .onEnded { 
                        if self.dragState == .good {
                            self.onEnded?($0.location, self.index, self.word)
                        }
                        self.dragAmount = .zero
                    }
                
            )
    }
    
    var dragColor : Color {
        switch dragState {
        case .unknown:
            return .black
        case .good:
            return .green
        case .bad:
            return .red
        }
    }
}

struct Word_Previews: PreviewProvider {
    static var previews: some View {
        WordView(word: "Item 1", index: 0)
    }
}
