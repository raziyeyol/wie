//
//  SearchBarView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 20/11/2023.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(
                     searchText.isEmpty ? Color.theme.secondaryText :
                        Color.theme.secondaryText
                )
            
            TextField("Search by name..", text: $searchText)
                .foregroundColor(Color.theme.secondaryText)
                .disableAutocorrection(true)
                .overlay(
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 10)
                        .foregroundColor(Color.theme.secondaryText)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            UIApplication.shared.endReceivingRemoteControlEvents()
                            searchText = ""
                        }
                    ,alignment: .trailing
                    )
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.secondaryText.opacity(0.15),
                        radius: 10, x: 0, y: 0)
        )
        .padding()
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
       
            SearchBarView(searchText: .constant(""))
               
      
        
    }
}
