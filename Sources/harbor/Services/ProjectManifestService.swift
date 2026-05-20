import Foundation

struct ProjectManifestService: Sendable {
    struct DetectedCommand: Identifiable, Hashable {
        let id = UUID()
        let command: String
        let source: String

        init(command: String, source: String) {
            self.command = command
            self.source = source
        }
    }

    func detectCommands(inDirectory directory: String) -> [DetectedCommand] {
        var commands: [DetectedCommand] = []

        let fm = FileManager.default

        let packageJsonPath = (directory as NSString).appendingPathComponent("package.json")
        if fm.fileExists(atPath: packageJsonPath) {
            commands.append(contentsOf: extractPackageJsonScripts(atPath: packageJsonPath))
        }

        let makefilePath = (directory as NSString).appendingPathComponent("Makefile")
        if fm.fileExists(atPath: makefilePath) {
            commands.append(contentsOf: extractMakefileTargets(atPath: makefilePath))
        }

        let cargoPath = (directory as NSString).appendingPathComponent("Cargo.toml")
        if fm.fileExists(atPath: cargoPath) {
            commands.append(DetectedCommand(command: "cargo run", source: "Cargo.toml"))
        }

        let pyprojectPath = (directory as NSString).appendingPathComponent("pyproject.toml")
        if fm.fileExists(atPath: pyprojectPath) {
            commands.append(contentsOf: extractPyprojectScripts(atPath: pyprojectPath))
        }

        let goModPath = (directory as NSString).appendingPathComponent("go.mod")
        if fm.fileExists(atPath: goModPath) {
            commands.append(DetectedCommand(command: "go run .", source: "go.mod"))
        }

        let mixPath = (directory as NSString).appendingPathComponent("mix.exs")
        if fm.fileExists(atPath: mixPath) {
            commands.append(DetectedCommand(command: "mix phx.server", source: "mix.exs"))
        }

        return commands
    }

    private func extractPackageJsonScripts(atPath path: String) -> [DetectedCommand] {
        guard let data = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let scripts = json["scripts"] as? [String: String]
        else { return [] }

        return scripts.map { key, _ in
            DetectedCommand(command: "npm run \(key)", source: "package.json")
        }.sorted { $0.command < $1.command }
    }

    private func extractMakefileTargets(atPath path: String) -> [DetectedCommand] {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8)
        else { return [] }

        var targets: [DetectedCommand] = []
        let lines = content.components(separatedBy: "\n")

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }

            if let colonIndex = trimmed.firstIndex(of: ":") {
                let targetPart = String(trimmed[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                guard !targetPart.isEmpty,
                      !targetPart.contains(" "),
                      !targetPart.hasPrefix(".")
                else { continue }

                targets.append(DetectedCommand(command: "make \(targetPart)", source: "Makefile"))
            }
        }

        return targets
    }

    private func extractPyprojectScripts(atPath path: String) -> [DetectedCommand] {
        guard let data = FileManager.default.contents(atPath: path),
              let content = String(data: data, encoding: .utf8)
        else { return [] }

        var commands: [DetectedCommand] = []
        var inScriptsSection = false

        for line in content.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("[") && trimmed.contains("scripts") {
                inScriptsSection = true
                continue
            }

            if inScriptsSection {
                if trimmed.hasPrefix("[") {
                    inScriptsSection = false
                    continue
                }

                if let eqIndex = trimmed.firstIndex(of: "=") {
                    let name = String(trimmed[..<eqIndex]).trimmingCharacters(in: .whitespaces)
                    if !name.isEmpty {
                        commands.append(DetectedCommand(command: name, source: "pyproject.toml"))
                    }
                }
            }
        }

        return commands
    }
}
