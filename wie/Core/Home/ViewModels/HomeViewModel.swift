//
//  HomeViewModel.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 07/11/2023.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    
    
    @Published var wordLevels: [WordLevel]
    
    @Published var searchText: String = ""
    
    @Published var currentWordLevel: WordLevel
    @Published var currentWordModel: WordModel
    @Published var showWordsList : Bool = false
    
    private let wordRepository: WordRepository
    private let audioService: AudioPlaying
    private let wordSearchGenerator: WordSearchGenerating
    
    init(wordRepository: WordRepository = DefaultWordRepository(),
         audioService: AudioPlaying = DefaultAudioPlayerService(),
         wordSearchGenerator: WordSearchGenerating = DefaultWordSearchGenerator()) {
        self.wordRepository = wordRepository
        self.audioService = audioService
        self.wordSearchGenerator = wordSearchGenerator
        
        self.searchText =  "Search by name"
        
        let levels = wordRepository.fetchWordLevels()
        self.wordLevels = levels
        
        if let firstWordLevel = levels.first {
            self.currentWordLevel = firstWordLevel
            
            if let firstWordModel = firstWordLevel.wordlist.first {
                self.currentWordModel = firstWordModel
            }
            else {
                self.currentWordModel = WordModel(fromString: "Default")
            }
        } else {
            
            self.wordLevels = []
            self.currentWordLevel = WordLevel(name: "Year 1", wordlist: [])
            self.currentWordModel =  WordModel(fromString: "Deafult")
        }
    }
    
    func toogleWordsList() {
        withAnimation(.easeInOut) {
            showWordsList.toggle()
        }
    }
    
    func showNextSet(wordLevel: WordLevel) {
        withAnimation(.easeInOut) {
            currentWordLevel = wordLevel
            currentWordModel = wordLevel.wordlist.first ?? WordModel(fromString: "Default")
            showWordsList = false
        }
    }
    
    func updateWord(wordModel: WordModel) {
        currentWordModel = wordModel
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

