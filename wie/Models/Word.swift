//
//  Word.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 09/11/2023.
//

import Foundation

class Word: Identifiable, Codable {
    var id: Int
    var uuid: UUID
    var levelId: UUID
    var word: String
    var audioKey: String?
    
    init(id: Int,
         uuid: UUID = UUID(),
         levelId: UUID = UUID(),
         word: String,
            audioKey: String? = nil) {
        self.id = id
        self.uuid = uuid
        self.levelId = levelId
        self.word = word
        self.audioKey = audioKey
    }

    required convenience init(fromString string: String) {
        let components = string.split(separator: ",")

        if components.count == 2,
           let parsedId = Int(components[0].trimmingCharacters(in: .whitespacesAndNewlines)) {
            let parsedWord = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            self.init(id: parsedId,
                      uuid: UUID(),
                      levelId: UUID(),
                      word: parsedWord,
                      audioKey: nil)
        }
        else {
            self.init(id: 0,
                      uuid: UUID(),
                      levelId: UUID(),
                      word: "",
                      audioKey: nil)
        }
    }
}
