//
//  WordLevel.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 21/11/2023.
//

import Foundation

class WordLevel: Identifiable, Equatable {

    let id = UUID().uuidString // local id created inside the app
    let remoteId: UUID?        // API/server-side id (if the device is online).This lets you sync or compare data correctly with the backend.
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
