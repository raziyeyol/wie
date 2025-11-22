//
//  WordSearchView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 26/10/2023.
//

import SwiftUI

struct WordSearchView: View {
    
    @EnvironmentObject private var vm: HomeViewModel
    @EnvironmentObject private var userProgress: UserProgress
    
    @State private var gameCompleted = false
    @State private var showReward = false
    @State private var hasAwardedReward = false
    @State private var foundWords: [String] = []
    @State private var tray: [WordModel] = []
    @State private var isLong = false
    @State private var showConfetti = false
  
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @StateObject private var game = WordSearchGame()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                Image("makeasentenceplain")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width)
                    .clipped()
                    .ignoresSafeArea()
                
                VStack(spacing:geometry.size.height * 0.02){
                    if showReward {
                        
                        withAnimation {
                            ZStack {
                                
                                ConfettiView()
                                    .onAppear(){
                                        vm.playSound(soundName: "game-bonus")
                                        vm.playSecondSound(soundName: "awesome")
                                    }
                                VStack {
                                    HStack(spacing: 20) {
                                        Image("iconReward")
                                        
                                        Text("Awesome")
                                            .font(.custom("ChalkboardSE-Regular", size: geometry.size.height * 0.05))
                                            .foregroundColor(Color.theme.accent)
                                            .multilineTextAlignment(.center)
                                            
                                                                      
                                            
                                        
                                        Image("iconReward")
                                    }
                                    Text("You've found all the words!")
                                        .font(.custom("ChalkboardSE-Regular", size: geometry.size.height * 0.05))
                                        .foregroundColor(Color.theme.accent)
                                        .multilineTextAlignment(.center)
                                        
                                                            
                                    
                                }
                                
                            }
                        }
                        .transition(.scale)
                        .onAppear {
                            if !hasAwardedReward {
                                hasAwardedReward = true
                                showConfetti = true
                                userProgress.earnStar()
                                userProgress.addPoints(10)
                                userProgress.recordScore(
                                    for: "WordSearch",
                                    points: foundWords.count * 10,
                                    stars: 1,
                                    duration: 0,
                                    metadata: ["words": foundWords])
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                vm.resetGame()
                                vm.currentWordLevel.wordlist.shuffle()
                                gameCompleted = false
                                showReward = false
                                hasAwardedReward = false
                                showConfetti = false
                                tray = Array(vm.currentWordLevel.wordlist.shuffled().prefix(6))
                                foundWords.removeAll()
                                game.setAimWords(tray.map { $0.word }, horizontalSizeClass: horizontalSizeClass ?? .compact)
                            }
                        }
                    } else {
                        GridView(game: game, onCompletion: {
                            gameCompleted = true
                            showReward = true
                        }, onUpdateWord: { matchedWords in
                            vm.playSound(soundName: matchedWords.last!)
                            foundWords = matchedWords
                        })
                        .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.8)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                        .shadow(color: Color.gray.opacity(0.5), radius: 20)
                        .onAppear {
                            tray = Array(vm.currentWordLevel.wordlist.shuffled().prefix(6))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                game.setAimWords(tray.map { $0.word }, horizontalSizeClass: horizontalSizeClass ?? .compact)
                            }
                            isLong = vm.currentWordLevel.name == "Year 5 & Year 6"
                        }
                        
                        VStack(spacing: 10) {
                            HStack(spacing: isLong ? (horizontalSizeClass == .regular ? 50 : 8) : (horizontalSizeClass == .regular ? 50 : 20)) {
                                ForEach(tray.indices.prefix(3), id: \.self) { number in
                                    WordBasicView(word: tray[number].word, index: tray[number].id, isFounded: foundWords.contains(tray[number].word), isLong: isLong)
                                    
                                }
                            }
                            
                            HStack(spacing: isLong ? (horizontalSizeClass == .regular ? 50 : 8) : (horizontalSizeClass == .regular ? 50 : 20)) {
                                ForEach(tray.indices.dropFirst(3).prefix(3), id: \.self) { number in
                                    WordBasicView(word: tray[number].word, index: tray[number].id, isFounded: foundWords.contains(tray[number].word), isLong: isLong)
                                    
                                }
                            }
                        }
                        .padding(horizontalSizeClass == .regular ?  12 : 10)
                        .frame(width: geometry.size.width * 0.92)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.theme.accent))
                        
                    }
                }
                .padding(10)
                .padding(.top, horizontalSizeClass == .regular ? 0 : 5)
                if showConfetti {
                    ConfettiView()
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
    }
}

struct WordSearchView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            WordSearchView()
                .environmentObject(HomeViewModel())
                .environmentObject(UserProgress.shared)
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro Max"))
                .previewDisplayName("iPhone 15 Pro Max")
            
            
            WordSearchView()
                .environmentObject(HomeViewModel())
                .environmentObject(UserProgress.shared)
                .previewDevice(PreviewDevice(rawValue: "iPad (10th generation)"))
                .previewDisplayName("iPad (10th generation)")
            
        }
    }
}
