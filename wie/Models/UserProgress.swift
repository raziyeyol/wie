//
//  UserProgress.swift
//  wie
//
//  Created by raziye yolasigmazoglu on 19/09/2024.
//

import Foundation

@MainActor
class UserProgress: ObservableObject {
    static let shared = UserProgress()
    
    @Published var totalStars: Int = 0
    @Published var totalPoints: Int = 0
    @Published var badgesEarned: [String] = []
    @Published var wordPlayCounts: [String: Int] = [:]
    
    private let defaults: UserDefaults
    private let playerSyncService: PlayerSyncing
    private let playerIdKey = "playerIdentifier"
    private var playerId: UUID? {
        didSet {
            defaults.set(playerId?.uuidString, forKey: playerIdKey)
        }
    }
    
    private init(playerSyncService: PlayerSyncing = DefaultPlayerSyncService(),
                 defaults: UserDefaults = .standard) {
        self.playerSyncService = playerSyncService
        self.defaults = defaults
        self.playerId = defaults.string(forKey: playerIdKey).flatMap(UUID.init(uuidString:))
        loadProgress()
        Task {
            await bootstrapRemoteState()
        }
    }
    
    func earnStar() {
        totalStars += 1
        saveProgress()
        checkForBadges()
    }
    
    func addPoints(_ points: Int) {
        totalPoints += points
        saveProgress()
        checkForBadges()
    }
    
    func earnBadge(_ badge: String) {
        if !badgesEarned.contains(badge) {
            badgesEarned.append(badge)
            saveProgress()
        }
    }
    
    func checkForBadges() {
        if totalStars == 10 && !badgesEarned.contains("10 Stars") {
            earnBadge("10 Stars")
        }
        if totalPoints == 100 && !badgesEarned.contains("100 Points") {
            earnBadge("100 Points")
        }
    }
    
    func incrementPlayCount(for word: String) {
        wordPlayCounts[word, default: 0] += 1
        if wordPlayCounts[word, default: 0] == 5 {
            earnStar()
            addPoints(10)
        }
        saveProgress()
    }
    
    func playCount(for word: String) -> Int {
        return wordPlayCounts[word, default: 0]
    }
    
    func recordScore(for gameMode: String, points: Int, stars: Int, duration: TimeInterval, metadata: [String: Any]? = nil) {
        guard let playerId else { return }
        let metadataJSON: String?
        if let metadata,
           let data = try? JSONSerialization.data(withJSONObject: metadata, options: []),
           let jsonString = String(data: data, encoding: .utf8) {
            metadataJSON = jsonString
        } else {
            metadataJSON = nil
        }
        let payload = ScorePayload(
            userId: playerId,
            gameMode: gameMode,
            points: points,
            stars: stars,
            durationSeconds: duration,
            metadataJson: metadataJSON)
        Task {
            try? await playerSyncService.submitScore(payload)
        }
    }
    
    private func saveProgress() {
        defaults.set(totalStars, forKey: "totalStars")
        defaults.set(totalPoints, forKey: "totalPoints")
        defaults.set(badgesEarned, forKey: "badgesEarned")
        
        if let data = try? JSONEncoder().encode(wordPlayCounts) {
            defaults.set(data, forKey: "wordPlayCounts")
        }
        syncProgress()
    }
    
    private func loadProgress() {
        totalStars = defaults.integer(forKey: "totalStars")
        totalPoints = defaults.integer(forKey: "totalPoints")
        badgesEarned = defaults.stringArray(forKey: "badgesEarned") ?? []
        
        if let data = defaults.data(forKey: "wordPlayCounts") {
            do {
                let decoded = try JSONDecoder().decode([String: Int].self, from: data)
                wordPlayCounts = decoded
            } catch {
                print("Failed to decode wordPlayCounts: \(error.localizedDescription)")
                wordPlayCounts = [:]
            }
        } else {
            wordPlayCounts = [:]
        }
    }
    
    private func bootstrapRemoteState() async {
        if playerId == nil {
            do {
                playerId = try await playerSyncService.ensurePlayerIdentifier(displayName: "Learner")
            } catch {
                return
            }
        }
        guard let playerId else { return }
        do {
            let profile = try await playerSyncService.fetchProfile(for: playerId)
            totalStars = profile.totalStars
            totalPoints = profile.totalPoints
            badgesEarned = profile.badges
        } catch {
            // Silently ignore when offline
        }
    }
    
    private func syncProgress() {
        guard let playerId else { return }
        let payload = ProgressPayload(
            userId: playerId,
            totalStars: totalStars,
            totalPoints: totalPoints,
            wordsPracticed: wordPlayCounts.values.reduce(0, +),
            badges: badgesEarned)
        Task {
            try? await playerSyncService.upsertProgress(payload)
        }
    }
}
