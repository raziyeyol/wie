//
//  WordLevel.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 21/11/2023.
//

import Foundation

class WordLevel: Identifiable, Equatable {
    
    let id = UUID().uuidString
    let remoteId: UUID?
    let name: String
    var wordlist: [WordModel]
    
    init(name: String, wordlist: [WordModel], remoteId: UUID? = nil) {
        self.name = name
        self.wordlist = wordlist
        self.remoteId = remoteId
    }
    
    static func == (lhs: WordLevel, rhs: WordLevel) -> Bool {
        lhs.id == rhs.id
    }
}
