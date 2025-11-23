//
//  ProgressCircleView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 27/10/2023.
//

import SwiftUI

struct ProgressCircle: View {
    var progress: Double  // A value between 0 and 1
    
    var body: some View {
        ZStack{
            ZStack {
                // Background Circle
                Circle()
                    .stroke(lineWidth: 6)
                    .foregroundColor(Color.gray.opacity(0.2))
                    
                
                // Progress Circle
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(Color.theme.accent, lineWidth: 6)
                    .rotationEffect(Angle(degrees: -90)) // To start the progress from the top
            }
            .frame(width: 30, height: 30)
        }
        .frame(width: 60, height: 60)
        .background(
            Circle()
                .fill(Color.theme.yellow.opacity(0.2)))
    
    }
}

struct ProgressCircleView: View {
    
    @State private var progressValue: Double = 0.3  // 50% filled
       
       var body: some View {
           VStack(spacing: 20) {
               ProgressCircle(progress: progressValue)
               
           }
       }
}

struct ProgressCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircleView()
    }
}


