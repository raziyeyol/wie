//
//  ConfettiView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 19/09/2024.
//

import SwiftUI

struct ConfettiView: View {
    @State private var confettiParticles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiParticles) { particle in
                    ConfettiParticleView(particle: particle)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
    }

    func generateConfetti(in size: CGSize) {
        let colors: [Color] = [.red, .green, .blue, .orange, .yellow, .pink, .purple]
        let confettiCount = 100

        confettiParticles = (0..<confettiCount).map { _ in
            ConfettiParticle(
                id: UUID(),
                color: colors.randomElement() ?? .red,
                x: CGFloat.random(in: 0...size.width),
                y: -10,
                angle: Angle(degrees: Double.random(in: 0...360)),
                speed: Double.random(in: 100...300),
                rotationSpeed: Double.random(in: -90...90)
            )
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    let color: Color
    let x: CGFloat
    var y: CGFloat
    var angle: Angle
    let speed: Double
    let rotationSpeed: Double
}

struct ConfettiParticleView: View {
    @State var particle: ConfettiParticle

    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: 8, height: 8)
            .rotationEffect(particle.angle)
            .position(x: particle.x, y: particle.y)
            .onAppear {
                withAnimation(Animation.linear(duration: particle.speed / 100).repeatForever(autoreverses: false)) {
                    particle.y += UIScreen.main.bounds.height + 20
                }
                withAnimation(Animation.linear(duration: particle.rotationSpeed / 100).repeatForever(autoreverses: false)) {
                    particle.angle += Angle(degrees: 360)
                }
            }
    }
}

