//
//  WrapView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 15/12/2023.
//

import SwiftUI

struct WrapView: View {
    
    @Binding var elements: [ElementModel]
    
    var onChanged: ((CGPoint, String) -> DragState)?
    var onEnded: ((CGPoint, Int, String) -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
                self.generateContent(in: geometry)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
            var width = CGFloat.zero
            var height = CGFloat.zero

            return ZStack(alignment: .topLeading) {
                ForEach(Array(elements.enumerated()), id: \.element.id) { index, platform in
                    if platform.isVisible {
                        WordView(word: platform.text, index: index, onChanged: self.onChanged, onEnded: self.onEnded)
                            .padding([.horizontal, .vertical], 4)
                            .alignmentGuide(.leading, computeValue: { d in
                                if (abs(width - d.width) > g.size.width)
                                {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                if platform.text == self.elements.last?.text {
                                    width = 0 //last item
                                } else {
                                    width -= d.width
                                }
                                return result
                            })
                            .alignmentGuide(.top, computeValue: {d in
                                let result = height
                                if platform.text == self.elements.last?.text {
                                    height = 0 // last item
                                }
                                return result
                            })
                    }
                    
                }
            }
    }
    
    
}

struct WrapView_Previews: PreviewProvider {
    static var previews: some View {
        WrapView(elements: .constant( [ElementModel(id: 1, text: "item 1", position: CGPoint(x: 10, y: 20), isVisible: true), ElementModel(id: 2, text: "item 2", position: CGPoint(x: 30, y: 40), isVisible: true)]))
    }
}
