//
//  WrapView2.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 17/01/2024.
//

import SwiftUI

struct WrapView2: View {
    
    var aimWords: [String] = []
    
    init(wordModelList: [Word]) {
        self.aimWords = wordModelList.map { $0.word }
    }
    
    var body: some View {
        GeometryReader { geometry in
                self.generateContent(in: geometry)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
            var width = CGFloat.zero
            var height = CGFloat.zero

            return ZStack(alignment: .topLeading) {
                ForEach(Array(aimWords.enumerated()), id: \.offset) { index, platform in
                    CardView(word: platform, maxWidth: g.size.width * 0.44, status: Status.empty)
                            .padding([.horizontal, .vertical], 10)
                            .alignmentGuide(.leading, computeValue: { d in
                                if (abs(width - d.width) > g.size.width)
                                {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                if platform == self.aimWords.last {
                                    width = 0 //last item
                                } else {
                                    width -= d.width
                                }
                                return result
                            })
                            .alignmentGuide(.top, computeValue: {d in
                                let result = height
                                if platform == self.aimWords.last  {
                                    height = 0 // last item
                                }
                                return result
                            })
                    
                }
            }
    }
}

struct WrapView2_Previews: PreviewProvider {
    static var previews: some View {
        WrapView2(wordModelList: [Word(fromString: "Word")]).background(Color.red)
    }
}
