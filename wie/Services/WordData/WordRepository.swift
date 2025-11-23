import Foundation

protocol WordRepository {
    func fetchWordLevels(forceRefresh: Bool) async throws -> [WordLevel]
}

extension WordRepository {
    func fetchWordLevels() async throws -> [WordLevel] {
        try await fetchWordLevels(forceRefresh: false)
    }
}

enum WordRepositoryError: Error {
    case requestFailed
    case decodingFailed
}

final class DefaultWordRepository: WordRepository {
    private let session: URLSession
    private let baseURL: URL
    private let cacheStore: WordCacheStore?
    private let bundle: Bundle
    private let decoder: JSONDecoder
    
    init(baseURL: URL = BackendConfiguration.baseURL,
         session: URLSession = .shared,
         cacheStore: WordCacheStore? = WordCacheStore.shared,
         bundle: Bundle = .main,
         decoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.session = session
        self.cacheStore = cacheStore
        self.bundle = bundle
        self.decoder = decoder
    }
    
    func fetchWordLevels(forceRefresh: Bool = false) async throws -> [WordLevel] {
        if !forceRefresh,
           let cachedLevels = try cacheStore?.load(),
           !cachedLevels.isEmpty {
            return mapRemoteLevels(cachedLevels)
        }
        
        do {
            let remoteLevels = try await fetchRemoteLevels()
            try cacheStore?.save(levels: remoteLevels)
            return mapRemoteLevels(remoteLevels)
        } catch {
            if let cachedLevels = try cacheStore?.load(), !cachedLevels.isEmpty {
                return mapRemoteLevels(cachedLevels)
            }
            return loadBundledFallback()
        }
    }
    
    private func fetchRemoteLevels() async throws -> [RemoteWordLevel] {
        let endpoint = baseURL.appendingPathComponent("api/wordlevels/with-words")
        let (data, response) = try await session.data(from: endpoint)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WordRepositoryError.requestFailed
        }
        do {
            return try decoder.decode([RemoteWordLevel].self, from: data)
        } catch {
            throw WordRepositoryError.decodingFailed
        }
    }
    
    private func loadBundledFallback() -> [WordLevel] {
        return [
            WordLevel(name: "Year 1",
                      description: "Common exception words for Year 1",
                      wordlist: loadWords(fileName: "year1CommonExceptionWords")),
            WordLevel(name: "Year 2",
                      description: "Common exception words for Year 2",
                      wordlist: loadWords(fileName: "year2CommonExceptionWords")),
            WordLevel(name: "Year 3 & Year 4",
                      description: "Common exception words for Years 3 and 4",
                      wordlist: loadWords(fileName: "year3And4CommonExceptionWords")),
            WordLevel(name: "Year 5 & Year 6",
                      description: "Common exception words for Years 5 and 6",
                      wordlist: loadWords(fileName: "year5And6CommonExceptionWords"))
        ]
    }
    
    private func loadWords(fileName: String) -> [Word] {
        guard let path = bundle.path(forResource: fileName, ofType: "strings"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: String] else {
            return []
        }
        
        return dictionary
            .values
            .filter { !$0.isEmpty }
            .compactMap { Word(fromString: $0) }
            .sorted { $0.id < $1.id }
    }
    
    private func mapRemoteLevels(_ levels: [RemoteWordLevel]) -> [WordLevel] {
        return levels.map { level in
            let words = level.words
                .sorted { lhs, rhs in
                    if lhs.sortOrder == rhs.sortOrder {
                        return lhs.text < rhs.text
                    }
                    return lhs.sortOrder < rhs.sortOrder
                }
                .map { remoteWord in
                    Word(id: remoteWord.sortOrder,
                              uuid: remoteWord.id,
                              levelId: remoteWord.levelId,
                              word: remoteWord.text,
                              audioKey: remoteWord.audioKey)
                }
            return WordLevel(name: level.name,
                              description: level.description,
                              wordlist: words,
                              remoteId: level.id)
        }
    }
}
