import Foundation

struct ServerProcess: Identifiable, Hashable, Codable, Sendable {
    var id: String { "\(pid):\(port)" }
    let pid: Int32
    let pgid: Int32
    let ppid: Int32
    let name: String
    let command: String
    let port: UInt16
    var status: SessionStatus
    let discoveredAt: Date
    let workingDirectory: String?

    var localURL: URL? {
        URL(string: "http://localhost:\(port)")
    }

    init(pid: Int32, pgid: Int32, ppid: Int32 = -1, name: String, command: String, port: UInt16, workingDirectory: String? = nil, status: SessionStatus = .active) {
        self.pid = pid
        self.pgid = pgid
        self.ppid = ppid
        self.name = name
        self.command = command
        self.port = port
        self.workingDirectory = workingDirectory
        self.status = status
        self.discoveredAt = Date()
    }

    enum CodingKeys: String, CodingKey {
        case pid, pgid, ppid, name, command, port, status, discoveredAt, workingDirectory
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pid = try container.decode(Int32.self, forKey: .pid)
        pgid = try container.decode(Int32.self, forKey: .pgid)
        ppid = try container.decodeIfPresent(Int32.self, forKey: .ppid) ?? -1
        name = try container.decode(String.self, forKey: .name)
        command = try container.decode(String.self, forKey: .command)
        port = try container.decode(UInt16.self, forKey: .port)
        status = try container.decode(SessionStatus.self, forKey: .status)
        discoveredAt = try container.decode(Date.self, forKey: .discoveredAt)
        workingDirectory = try container.decodeIfPresent(String.self, forKey: .workingDirectory)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pid, forKey: .pid)
        try container.encode(pgid, forKey: .pgid)
        try container.encode(ppid, forKey: .ppid)
        try container.encode(name, forKey: .name)
        try container.encode(command, forKey: .command)
        try container.encode(port, forKey: .port)
        try container.encode(status, forKey: .status)
        try container.encode(discoveredAt, forKey: .discoveredAt)
        try container.encodeIfPresent(workingDirectory, forKey: .workingDirectory)
    }
}
