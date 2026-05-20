import Foundation

struct PersistenceService: Sendable {
    private static let sessionsKey = "harbor.knownSessions"
    private static let favoritesKey = "harbor.favoriteServices"

    func loadSessions() -> [ServerProcess] {
        guard let data = UserDefaults.standard.data(forKey: Self.sessionsKey),
              let sessions = try? JSONDecoder().decode([ServerProcess].self, from: data)
        else { return [] }
        return sessions
    }

    func saveSessions(_ sessions: [ServerProcess]) {
        let data = try? JSONEncoder().encode(sessions)
        UserDefaults.standard.set(data, forKey: Self.sessionsKey)
    }

    func loadFavoriteServices() -> [FavoriteService] {
        guard let data = UserDefaults.standard.data(forKey: Self.favoritesKey),
              let favorites = try? JSONDecoder().decode([FavoriteService].self, from: data)
        else { return [] }
        return favorites
    }

    func saveFavoriteServices(_ favorites: [FavoriteService]) {
        let data = try? JSONEncoder().encode(favorites)
        UserDefaults.standard.set(data, forKey: Self.favoritesKey)
    }
}
