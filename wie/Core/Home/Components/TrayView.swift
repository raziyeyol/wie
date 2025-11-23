//
//  Tray.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 24/04/2024.
//

import SwiftUI

struct TrayView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 20 : 10)
                .stroke(Color.theme.accent, lineWidth: 8)
                .background(Color.theme.accent)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .shadow( radius: 5, x: 0, y: 0)
                .cornerRadius(10)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct TrayView_Previews: PreviewProvider {
    static var previews: some View {
        TrayView()
    }
}
