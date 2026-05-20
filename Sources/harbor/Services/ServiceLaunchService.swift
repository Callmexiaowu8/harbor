import AppKit
import Foundation

struct ServiceLaunchService: Sendable {
    enum LaunchError: Error, LocalizedError {
        case scriptExecutionFailed(String)
        case terminalNotAvailable

        var errorDescription: String? {
            switch self {
            case .scriptExecutionFailed(let message):
                "Failed to launch in Terminal: \(message)"
            case .terminalNotAvailable:
                "Terminal.app is not available"
            }
        }
    }

    func launch(workingDirectory: String, startCommand: String) throws {
        let terminalURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal")
        guard terminalURL != nil else {
            throw LaunchError.terminalNotAvailable
        }

        let escapedDir = workingDirectory
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let escapedCmd = startCommand
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Terminal"
            activate
            do script "cd \\"\(escapedDir)\\" && \(escapedCmd)"
        end tell
        """

        let appleScript = NSAppleScript(source: script)
        var errorDict: NSDictionary?
        appleScript?.executeAndReturnError(&errorDict)

        if let error = errorDict {
            let message = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
            throw LaunchError.scriptExecutionFailed(message)
        }
    }

    func launchInBackground(workingDirectory: String, startCommand: String, serviceName: String) throws {
        let fm = FileManager.default

        let logsDir = (NSHomeDirectory() as NSString).appendingPathComponent(".harbor/logs")
        if !fm.fileExists(atPath: logsDir) {
            try fm.createDirectory(atPath: logsDir, withIntermediateDirectories: true)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let sanitized = serviceName.replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: " ", with: "-")
        let logFileName = "\(sanitized)-\(timestamp).log"
        let logPath = (logsDir as NSString).appendingPathComponent(logFileName)

        fm.createFile(atPath: logPath, contents: nil)
        guard let logHandle = FileHandle(forWritingAtPath: logPath) else {
            throw LaunchError.scriptExecutionFailed("Cannot create log file at \(logPath)")
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        let escapedCommand = startCommand.replacingOccurrences(of: "'", with: "'\\''")
        process.arguments = ["-l", "-i", "-c", "nohup /bin/zsh -c '\(escapedCommand)'"]

        let dir = workingDirectory.isEmpty
            ? NSHomeDirectory()
            : workingDirectory
        process.currentDirectoryURL = URL(fileURLWithPath: dir)

        process.standardOutput = logHandle
        process.standardError = logHandle

        try process.run()
    }
}
