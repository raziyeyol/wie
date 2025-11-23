//
//  BadgesView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 19/09/2024.
//

import SwiftUI

struct BadgesView: View {
    
    @ObservedObject var userProgress = UserProgress.shared
        
        var body: some View {
            VStack {
                Text("Badges")
                    .font(.largeTitle)
                    .padding()
                ScrollView {
                    ForEach(userProgress.badgesEarned, id: \.self) { badge in
                        HStack {
                            Image(systemName: "badge.fill")
                                .foregroundColor(.yellow)
                            Text(badge)
                                .font(.headline)
                        }
                        .padding()
                    }
                }
            }
        }
}

#Preview {
    BadgesView()
}
