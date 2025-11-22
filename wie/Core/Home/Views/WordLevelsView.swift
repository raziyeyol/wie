//
//  WordLevelsView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 15/11/2023.
//

import SwiftUI

struct WordLevelsView: View {
    
    @State private var selection: String?
    @EnvironmentObject private var vm: HomeViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        List {
            ForEach(vm.wordLevels) { level in
                Button {
                    vm.showNextSet(wordLevel: level)
                } label: {
                    listRowView(name: level.name)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            
            }
        }
        .listStyle(PlainListStyle())
        .environment(\.defaultMinListRowHeight, 32)
        .frame(maxHeight: listMaxHeight)
      
    }
}

struct WordLevelsView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone 15 Pro Max", "iPad (10th generation)"], id: \.self) { deviceName in
            WordLevelsView()
                .environmentObject(HomeViewModel())
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}

extension WordLevelsView {
    
    
    private var listMaxHeight: CGFloat? {
        horizontalSizeClass == .regular ? 200 : 180
    }
    
    private func listRowView(name: String) -> some View {
        VStack(spacing: 0) {
            Text(name)
                .font(.custom("ChalkboardSE-Regular", size: horizontalSizeClass == .regular ? 24 : 20))
                .foregroundColor(Color.theme.accent)
        }
    }
}

