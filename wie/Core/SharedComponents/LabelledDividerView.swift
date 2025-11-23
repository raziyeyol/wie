//
//  LabelledDividerView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 15/12/2023.
//

import SwiftUI

struct DividerView: View {

     var body: some View {
         VStack() { Divider().background(Color.gray) }
     }
}

struct LabelledDividerView: View {
    let label: String
    let color: Color

     init(label: String = "", color: Color = .gray) {
         self.color = color
         self.label = label
     }

     var body: some View {
  
             HStack {
                 line
                 Text(label).foregroundColor(color)
                 line
             }
             
     }

     var line: some View {
         VStack { Divider().background(color) }
     }
}

struct LabelledDividerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            DividerView()
            LabelledDividerView(label: "Put here")
        }
    }
}
