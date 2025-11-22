import Foundation

protocol PlayerSyncing {
    func ensurePlayerIdentifier(displayName: String) async throws -> UUID
    func fetchProfile(for userId: UUID) async throws -> UserProfileResponse
    func upsertProgress(_ payload: ProgressPayload) async throws
    func submitScore(_ payload: ScorePayload) async throws
}

final class DefaultPlayerSyncService: PlayerSyncing {
    private let baseURL: URL
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(baseURL: URL = BackendConfiguration.baseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func ensurePlayerIdentifier(displayName: String) async throws -> UUID {
        let request = CreateUserPayload(displayName: displayName, avatarUrl: nil)
        let url = baseURL.appendingPathComponent("api/users")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try encoder.encode(request)
        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PlayerSyncError.invalidResponse
        }
        let profile = try decoder.decode(UserProfileResponse.self, from: data)
        return profile.id
    }
    
    func fetchProfile(for userId: UUID) async throws -> UserProfileResponse {
        let url = baseURL.appendingPathComponent("api/users/\(userId.uuidString)")
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PlayerSyncError.invalidResponse
        }
        return try decoder.decode(UserProfileResponse.self, from: data)
    }
    
    func upsertProgress(_ payload: ProgressPayload) async throws {
        let url = baseURL
            .appendingPathComponent("api/users")
            .appendingPathComponent(payload.userId.uuidString)
            .appendingPathComponent("progress")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(payload)
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PlayerSyncError.invalidResponse
        }
    }
    
    func submitScore(_ payload: ScorePayload) async throws {
        let url = baseURL
            .appendingPathComponent("api/users")
            .appendingPathComponent(payload.userId.uuidString)
            .appendingPathComponent("scores")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(payload)
        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PlayerSyncError.invalidResponse
        }
    }
}

struct UserProfileResponse: Codable {
    let id: UUID
    let displayName: String
    let avatarUrl: String?
    let createdAtUtc: Date
    let totalStars: Int
    let totalPoints: Int
    let wordsPracticed: Int
    let badges: [String]
}

struct ProgressSnapshotResponse: Codable {
    let id: UUID
    let userId: UUID
    let totalStars: Int
    let totalPoints: Int
    let wordsPracticed: Int
    let badges: [String]
    let capturedAtUtc: Date
}

struct CreateUserPayload: Encodable {
    let displayName: String
    let avatarUrl: String?
}

struct ProgressPayload: Encodable {
    let userId: UUID
    let totalStars: Int
    let totalPoints: Int
    let wordsPracticed: Int
    let badges: [String]
}

struct ScorePayload: Encodable {
    let userId: UUID
    let gameMode: String
    let points: Int
    let stars: Int
    let durationSeconds: Double
    let metadataJson: String?
}

enum PlayerSyncError: Error {
    case invalidResponse
}
