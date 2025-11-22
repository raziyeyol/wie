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
    
    required init(fromString string: String) {
        
        let components = string.split(separator: ",")
            
        if components.count == 2 {
            self.id = Int(components[0].trimmingCharacters(in: .whitespacesAndNewlines))!
            self.uuid = UUID()
            self.word = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        else{
            self.id =  10
            self.uuid = UUID()
            self.word = ""
        }
    }
}
