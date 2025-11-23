//
//  BackButtonView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 18/03/2024.
//

import SwiftUI

struct BackButtonView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                            Text("Back")
                                .font(.headline)
                                .frame(width: 80, height: 20)
                        })
                        .buttonStyle(.borderedProminent )
        
         
    }
}

#Preview {
    BackButtonView()
}
