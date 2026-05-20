import Foundation

struct FavoriteService: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var workingDirectory: String
    var startCommand: String
    var port: UInt16?
    var projectName: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case workingDirectory
        case startCommand
        case port
        case projectName
        case createdAt
    }

    init(
        id: UUID = UUID(),
        name: String,
        workingDirectory: String,
        startCommand: String,
        port: UInt16? = nil,
        projectName: String? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.workingDirectory = workingDirectory
        self.startCommand = startCommand
        self.port = port
        self.projectName = projectName
        self.createdAt = createdAt ?? Date()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.workingDirectory = try container.decode(String.self, forKey: .workingDirectory)
        self.startCommand = try container.decode(String.self, forKey: .startCommand)
        self.port = try container.decodeIfPresent(UInt16.self, forKey: .port)
        self.projectName = try container.decodeIfPresent(String.self, forKey: .projectName)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(workingDirectory, forKey: .workingDirectory)
        try container.encode(startCommand, forKey: .startCommand)
        try container.encodeIfPresent(port, forKey: .port)
        try container.encodeIfPresent(projectName, forKey: .projectName)
        try container.encode(createdAt, forKey: .createdAt)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: FavoriteService, rhs: FavoriteService) -> Bool {
        lhs.id == rhs.id
    }
}
