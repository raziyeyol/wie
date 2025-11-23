//
//  HomeViewModel.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 07/11/2023.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var wordLevels: [WordLevel]
    @Published var searchText: String = "Search by name"
    @Published var currentWordLevel: WordLevel
    @Published var currentWord: Word
    @Published var showWordsList: Bool = false
    
    private static let placeholderWord = Word(id: 0, word: "")
    private let wordRepository: WordRepository
    private let audioService: AudioPlaying
    private let wordSearchGenerator: WordSearchGenerating
    
    init(wordRepository: WordRepository = DefaultWordRepository(),
         audioService: AudioPlaying = DefaultAudioPlayerService(),
         wordSearchGenerator: WordSearchGenerating = DefaultWordSearchGenerator(),
         initialWordLevels: [WordLevel]? = nil) {
        self.wordRepository = wordRepository
        self.audioService = audioService
        self.wordSearchGenerator = wordSearchGenerator
        
        if let initialLevels = initialWordLevels, let firstLevel = initialLevels.first {
            self.wordLevels = initialLevels
            self.currentWordLevel = firstLevel
            self.currentWord = firstLevel.wordlist.first ?? Self.placeholderWord
        } else {
            self.wordLevels = []
            self.currentWordLevel = WordLevel(name: "Loading", wordlist: [])
            self.currentWord = Self.placeholderWord
            Task {
                await loadWordLevels()
            }
        }
    }
    
    func loadWordLevels(forceRefresh: Bool = false) async {
        do {
            let levels = try await wordRepository.fetchWordLevels(forceRefresh: forceRefresh)
            applyLevels(levels)
        } catch {
            if wordLevels.isEmpty {
                wordLevels = []
                currentWordLevel = WordLevel(name: "Year 1", wordlist: [])
                currentWord = Self.placeholderWord
            }
        }
    }
    
    private func applyLevels(_ levels: [WordLevel]) {
        guard let firstLevel = levels.first else { return }
        wordLevels = levels
        currentWordLevel = firstLevel
        currentWord = firstLevel.wordlist.first ?? Self.placeholderWord
    }
    
    func toogleWordsList() {
        withAnimation(.easeInOut) {
            showWordsList.toggle()
        }
    }
    
    func showNextSet(wordLevel: WordLevel) {
        withAnimation(.easeInOut) {
            currentWordLevel = wordLevel
            currentWord = wordLevel.wordlist.first ?? Self.placeholderWord
            showWordsList = false
        }
    }
    
    func updateWord(_ word: Word) {
        currentWord = word
    }
    
    func nextButtonPressed(word: String) -> String? {
        
        guard let currentIndex = currentWordLevel.wordlist.firstIndex(where: {$0.word == word}) else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        guard currentWordLevel.wordlist.indices.contains(nextIndex) else {
            return nil
        }
        
        return currentWordLevel.wordlist[nextIndex].word
        
    }
    
    func resetGame(){
        //foundWords.removeAll()
        currentWordLevel.wordlist = currentWordLevel.wordlist.shuffled()
    }
    
    func playSound(soundName: String) {
        
        audioService.playPrimary(named: soundName)
    }
    
    
    func playSound(named soundName: String, withExtension ext: String = "mp3") {
        audioService.playPrimary(named: soundName)
    }
    
    func playSlowSound(soundName: String) {
        
        audioService.playPrimarySlow(named: soundName)
    }
    
    func playSecondSound(soundName: String) {
        
        audioService.playSecondary(named: soundName)
    }
    
    func playSlowSecondSound(soundName: String) {
        
        audioService.playSecondarySlow(named: soundName)
    }
   
    
    func generateWordSearchGrid(rows: Int, columns: Int, words: [String]) -> [[Character]] {
        return wordSearchGenerator.makeGrid(rows: rows, columns: columns, words: words)
    }
}

