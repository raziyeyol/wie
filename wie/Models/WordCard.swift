//
//  WordCard.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 01/05/2024.
//

import Foundation

class WordCard: Identifiable, Equatable {
    
    let id = UUID().uuidString
    let word: Word
    let status: Status
    
    init(word: Word, status: Status) {
        self.word = word
        self.status = status
    }
    
    static func == (lhs: WordCard, rhs: WordCard) -> Bool {
        lhs.id == rhs.id
    }
}
