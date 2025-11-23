//
//  CustomNavLinkView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 19/03/2024.
//

import SwiftUI



struct CustomNavLinkView<Label: View, Destination:View>: View {
    
    let destination: Destination
    let label: Label
    
    init(destination: Destination, @ViewBuilder label: () -> Label){
        self.destination = destination
        self.label = label()
    }
    
    var body: some View {
        NavigationLink(
            destination: 
                CustomNavBarContainerView(content: {
                    destination
                })
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden()
            ,
            label: {
                label
            }
        )
        
    }
}

struct CustomNavLinkView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavView {
            CustomNavLinkView(destination: Text("Destination")) {
                Text("Navigate")
            }
        }
    }
}
