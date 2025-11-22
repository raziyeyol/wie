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
    let yearBand: String
    let difficulty: String
    let description: String
    var wordlist: [WordModel]
    
    init(name: String,
         yearBand: String = "",
         difficulty: String = "",
         description: String = "",
         wordlist: [WordModel],
         remoteId: UUID? = nil) {
        self.name = name
        self.yearBand = yearBand
        self.difficulty = difficulty
        self.description = description
        self.wordlist = wordlist
        self.remoteId = remoteId
    }
    
    static func == (lhs: WordLevel, rhs: WordLevel) -> Bool {
        lhs.id == rhs.id
    }
}
