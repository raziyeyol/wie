import Foundation
import SQLite3

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

struct RemoteWordLevel: Codable {
    let id: UUID
    let name: String
    let yearBand: String
    let difficulty: String
    let description: String
    let words: [RemoteWord]
}

struct RemoteWord: Codable {
    let id: UUID
    let levelId: UUID
    let text: String
    let phonetic: String?
    let audioKey: String?
    let sortOrder: Int
    let tags: [String]
}

final class WordCacheStore {
    static let shared = try? WordCacheStore()
    private let queue = DispatchQueue(label: "WordCacheStoreQueue")
    private var database: OpaquePointer?

    init(fileManager: FileManager = .default) throws {
        let directory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("WordCache", isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        let databaseURL = directory.appendingPathComponent("words.sqlite")
        if sqlite3_open(databaseURL.path, &database) != SQLITE_OK {
            throw WordCacheError.unableToOpenDatabase
        }

        try createTable()
    }

    deinit {
        sqlite3_close(database)
    }

    func save(levels: [RemoteWordLevel]) throws {
        guard let database else { throw WordCacheError.unableToOpenDatabase }
        let data = try JSONEncoder().encode(levels)

        try queue.sync {
            let upsertSQL = "REPLACE INTO word_cache(id, payload, updated_at) VALUES(1, ?, strftime('%s','now'))"
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(database, upsertSQL, -1, &statement, nil) == SQLITE_OK else {
                throw WordCacheError.statementPreparationFailed
            }
            defer { sqlite3_finalize(statement) }

            data.withUnsafeBytes { rawBufferPointer in
                let bytes = rawBufferPointer.baseAddress?.assumingMemoryBound(to: UInt8.self)
                sqlite3_bind_blob(statement, 1, bytes, Int32(data.count), SQLITE_TRANSIENT)
            }

            if sqlite3_step(statement) != SQLITE_DONE {
                throw WordCacheError.executionFailed
            }
        }
    }

    func load() throws -> [RemoteWordLevel]? {
        guard let database else { throw WordCacheError.unableToOpenDatabase }
        return try queue.sync {
            let querySQL = "SELECT payload FROM word_cache WHERE id = 1"
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(database, querySQL, -1, &statement, nil) == SQLITE_OK else {
                throw WordCacheError.statementPreparationFailed
            }
            defer { sqlite3_finalize(statement) }

            if sqlite3_step(statement) == SQLITE_ROW,
               let blobPointer = sqlite3_column_blob(statement, 0) {
                let blobSize = Int(sqlite3_column_bytes(statement, 0))
                let data = Data(bytes: blobPointer, count: blobSize)
                return try JSONDecoder().decode([RemoteWordLevel].self, from: data)
            }
            return nil
        }
    }

    private func createTable() throws {
        guard let database else { throw WordCacheError.unableToOpenDatabase }
        let createSQL = """
        CREATE TABLE IF NOT EXISTS word_cache (
            id INTEGER PRIMARY KEY,
            payload BLOB NOT NULL,
            updated_at REAL NOT NULL
        );
        """

        if sqlite3_exec(database, createSQL, nil, nil, nil) != SQLITE_OK {
            throw WordCacheError.executionFailed
        }
    }
}

enum WordCacheError: Error {
    case unableToOpenDatabase
    case statementPreparationFailed
    case executionFailed
}
