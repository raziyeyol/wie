//
//  MakeSentenceView.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 26/10/2023.
//

import SwiftUI

struct ElementModel: Identifiable, Codable {
    let id: Int
    var text: String
    var position: CGPoint
    var isVisible: Bool
}

struct WhatsOnTheTrayView: View {
    @EnvironmentObject private var vm: HomeViewModel
    @State private var showTray = false
    @State private var wordList: [WordModel] = []
    @State private var tray: [WordModel] = []
    
    @EnvironmentObject private var userProgress: UserProgress
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                Image("makeasentenceplain")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width)
                    .clipped()
                    .ignoresSafeArea()
                
                VStack(spacing: 20)   {
                    if showTray {
                        BottomTrayView(showTray: $showTray, wordList: $wordList, tray: $tray, resetGameAction: resetGame)
                    } else {
                        
                        instructionView(geometry: geometry)
                            .padding(.horizontal)
                        
                        //Spacer()
                        
                        VStack(spacing:10) {
                            
                            Text("How many you can remember")
                                .font(.custom("ChalkboardSE-Regular", size: (horizontalSizeClass == .regular ?  geometry.size.height * 0.025 : geometry.size.height * 0.028)))
                                    .foregroundColor(Color.black.opacity(0.6))
                            
                            Button(action: {
                                withAnimation{
                                    showTray.toggle()
                                }
                            }) {
                                HStack {
                                    Text("Let's See")
                                        .font(.custom("ChalkboardSE-Bold", size: 24))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 7)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                    
                                    
                                }
                                .padding(.horizontal, (horizontalSizeClass == .regular ? 80 : 60))
                                .padding(.vertical, (horizontalSizeClass == .regular ? 20 : 10))
                                //.padding()
                                .background(Color.theme.iconColor)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                            }
                            .padding(.bottom, (horizontalSizeClass == .regular ? 45 : 10))
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                    }
                    
                }
                .padding(.horizontal, horizontalSizeClass == .regular ? 20 : 0)
                .onAppear {
                    loadTrayWords()
                    vm.playSlowSound(soundName: "LookCarefully")
                    //vm.playVerySlowSound(soundName: "HowManyYouCan")
                }
            }
        }
    }
    
    private func loadTrayWords() {
        let shuffledWordList = vm.currentWordLevel.wordlist.shuffled()
        wordList = Array(shuffledWordList.prefix(8))
        tray = Array(wordList.shuffled().prefix(6))
    }
    
    private func resetGame() {
        showTray = false
        loadTrayWords()
    }
    
    @ViewBuilder
    private func instructionView(geometry: GeometryProxy) -> some View {
        VStack() {
            Text("Look carefully at the words on the tray!")
                .font(.custom("ChalkboardSE-Regular", size: horizontalSizeClass == .regular ? 26 : 21))
                .foregroundColor(Color.black.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.vertical,(horizontalSizeClass == .regular ? 25 : 10))
                
            
            TrayContentStack(tray: $tray, geometry: geometry)
            
        }
    }
}

struct TrayContentStack: View {
    @Binding var tray: [WordModel]
    let geometry: GeometryProxy
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        let count = tray.count
        
        ZStack {
            TrayView()
            VStack(alignment: .center, spacing: (horizontalSizeClass == .regular ?  12 : 8)) {
                ForEach(Array(stride(from: 0, to: count, by: 2)), id: \.self) { index in
                    HStack(alignment: .top, spacing: (horizontalSizeClass == .regular ?  12 : 8)) {
                        cardView(word: tray[index], maxWidth: (geometry.size.width - 48) / 2)
                        if index + 1 < count {
                            cardView(word: tray[index + 1], maxWidth: (geometry.size.width - 48) / 2)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
    }
    
    private func cardView(word: WordModel, maxWidth: CGFloat) -> some View {
        CardView(
            word: word.word,
            maxWidth: maxWidth,
            status: .empty
        )
    }
}

struct BottomTrayView: View {
    @Binding var showTray: Bool
    @Binding var wordList: [WordModel]
    @Binding var tray: [WordModel]
    
    var resetGameAction: () -> Void
    
    @State private var selectedWords: Set<String> = []
    @State private var score: Int = 0
    @State private var showCongratulations = false
    @State private var hasCheckedAnswer = false
    @State private var hasAwardedReward = false
    @State private var showConfetti = false
    private let maxSelection = 6
    
    @ObservedObject var vm = HomeViewModel()
    @ObservedObject var userProgress = UserProgress.shared
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack {
            if showCongratulations {
                congratulatoryView()
                    .onAppear {
                        vm.playSound(soundName: "game-bonus")
                        vm.playSecondSound(soundName: "awesome")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            resetGameState()
                        }
                    }
                
            } else {
                VStack( ) {
                    if score > 0 {
                        feedbackMessage()
                            .padding()
                    } else {
                        instructionText()
                    }
                    
                    wordPairsStack()
                        .cornerRadius(20)
                        .shadow(radius: 3)
                        .padding(.bottom,40)
                        .disabled(showCongratulations)
                    
                
                }
               
            }
            
        }
        .padding(.horizontal, horizontalSizeClass == .regular ? 30 : 0)
        .onAppear() {
            score > 0 ? vm.playSlowSound(soundName: "TapOnTheWord") : vm.playSlowSound(soundName: "TapOnTheWord")
        }
    }
    
    private func resetGameState() {
        selectedWords.removeAll()
        score = 0
        hasAwardedReward = false
        showCongratulations = false
        resetGameAction()
    }
    
    @ViewBuilder
    private func instructionText() -> some View {
        Text("Tap on the words you remember seeing!")
            .font(.custom("ChalkboardSE-Regular", size: horizontalSizeClass == .regular ? 26 : 21))
            .foregroundColor(Color.black.opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, (horizontalSizeClass == .regular ? 25 : 10))
    }
    
    @ViewBuilder
    private func feedbackMessage() -> some View {
        if score == 6 {
            Text("Amazing! You remembered all the words! 🎉")
                .font(.custom("ChalkboardSE-Regular", size: horizontalSizeClass == .regular ? 26 : 22))
                .foregroundColor(Color.black.opacity(0.6))
                .multilineTextAlignment(.center)
           
        } else if score >= 3 {
            Text("Great job! You remembered \(score) out of 6 words!")
                .foregroundColor(Color.black.opacity(0.6))
                .font(.custom("ChalkboardSE-Regular", size: horizontalSizeClass == .regular ? 26 : 22))
                .multilineTextAlignment(.center)
         
        } else {
            Text("Good try! Let's practice and try again!")
                .font(.custom("ChalkboardSE-Regular", size: horizontalSizeClass == .regular ? 26 : 22))
                .foregroundColor(Color.black.opacity(0.6))
                .multilineTextAlignment(.center)
                
        }
    }
    
    @ViewBuilder
    private func wordPairsStack() -> some View {
        let shuffledWordList = wordList.shuffled()
        let count = shuffledWordList.count
        
        VStack(alignment: .center, spacing:  (horizontalSizeClass == .regular ?  12 : 8)) {
            ForEach(Array(stride(from: 0, to: count, by: 2)), id: \.self) { index in
                HStack(alignment: .top, spacing:  (horizontalSizeClass == .regular ?  12 : 8)) {
                    cardView(word: shuffledWordList[index], maxWidth: (UIScreen.main.bounds.width - 48) / 2)
                    if index + 1 < count {
                        cardView(word: shuffledWordList[index + 1], maxWidth: (UIScreen.main.bounds.width - 48) / 2)
                            
                    }
                }
            }
        }
        .padding(.bottom)
    }
    
    private func cardView(word: WordModel, maxWidth: CGFloat) -> some View {
        CardView(
            word: word.word,
            maxWidth: maxWidth,
            backgorundColor: !selectedWords.contains(word.word) ? nil : Color.theme.accent,
            status: .empty
        )
        .onTapGesture {
            if !showCongratulations {
                toggleSelection(of: word.word)
                vm.playSound(soundName: word.word)
            }
        }
    }
    
    private func toggleSelection(of word: String) {
        if selectedWords.contains(word) {
            selectedWords.remove(word)
            if score > 0 {
                score = 0
            }
        } else if selectedWords.count < maxSelection {
            selectedWords.insert(word)
            if selectedWords.count == maxSelection {
                checkAnswers()
            }
        }
    }
    
    private func checkAnswers() {
        let common = selectedWords.intersection(tray.map { $0.word })
        score = common.count
        if score == maxSelection {
            showCongratulations = true
        }
        userProgress.recordScore(
            for: "WhatsOnTheTray",
            points: score * 5,
            stars: score == maxSelection ? 1 : 0,
            duration: 0,
            metadata: ["score": score])
    }
    
    @ViewBuilder
    private func congratulatoryView() -> some View {
        GeometryReader { geometry in
        withAnimation {
            ZStack {
                
                ConfettiView()
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
        }
    }
}

struct MakeSentenceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            WhatsOnTheTrayView()
                .environmentObject(HomeViewModel())
                .ignoresSafeArea()
                .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro Max"))
                .previewDisplayName("iPhone 15 Pro Max")
            
            
            WhatsOnTheTrayView()
                .environmentObject(HomeViewModel())
                .ignoresSafeArea()
                .previewDevice(PreviewDevice(rawValue: "iPad (10th generation)"))
                .previewDisplayName("iPad (10th generation)")
            
        }
    }
}
