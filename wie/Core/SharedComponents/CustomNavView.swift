//
//  CustomNavView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 19/03/2024.
//

import SwiftUI

struct CustomNavView<Content: View>: View {
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content){
        self.content = content()
    }
    
    var body: some View {
        NavigationView{
            CustomNavBarContainerView {
                content
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomNavView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavView {
            Color.green.ignoresSafeArea()
        }
    }
}
