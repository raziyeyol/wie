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
    let description: String
    var wordlist: [Word]
    
    init(name: String,
         description: String = "",
         wordlist: [Word],
         remoteId: UUID? = nil) {
        self.name = name
        self.description = description
        self.wordlist = wordlist
        self.remoteId = remoteId
    }
    
    static func == (lhs: WordLevel, rhs: WordLevel) -> Bool {
        lhs.id == rhs.id
    }
}
