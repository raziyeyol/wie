//
//  WordModel.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 09/11/2023.
//

import Foundation

class WordModel:  Identifiable, Codable {
    var id: Int
    var uuid: UUID
    var word: String
    
    init(id: Int, uuid: UUID = UUID(), word: String) {
        self.id = id
        self.uuid = uuid
        self.word = word
    }

    required convenience init(fromString string: String) {
        let components = string.split(separator: ",")

        if components.count == 2,
           let parsedId = Int(components[0].trimmingCharacters(in: .whitespacesAndNewlines)) {
            let parsedWord = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            self.init(id: parsedId, uuid: UUID(), word: parsedWord)
        }
        else {
            self.init(id: 0, uuid: UUID(), word: "")
        }
    }
}
