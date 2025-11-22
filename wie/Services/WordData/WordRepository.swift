import Foundation

protocol WordRepository {
    func fetchWordLevels() -> [WordLevel]
}

final class DefaultWordRepository: WordRepository {
    private let bundle: Bundle
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
    func fetchWordLevels() -> [WordLevel] {
        return [
            WordLevel(name: "Year 1", wordlist: loadWords(fileName: "year1CommonExceptionWords")),
            WordLevel(name: "Year 2", wordlist: loadWords(fileName: "year2CommonExceptionWords")),
            WordLevel(name: "Year 3 & Year 4", wordlist: loadWords(fileName: "year3And4CommonExceptionWords")),
            WordLevel(name: "Year 5 & Year 6", wordlist: loadWords(fileName: "year5And6CommonExceptionWords"))
        ]
    }
    
    private func loadWords(fileName: String) -> [WordModel] {
        guard let path = bundle.path(forResource: fileName, ofType: "strings"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: String] else {
            assertionFailure("Missing or invalid file: \(fileName).strings")
            return []
        }
        
        let trimmedDictionary = dictionary.filter { !$0.value.isEmpty }
        
        return trimmedDictionary.compactMap { WordModel(fromString: $0.value) }
            .sorted { $0.id < $1.id }
    }
}
