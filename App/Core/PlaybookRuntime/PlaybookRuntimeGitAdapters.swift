import Foundation

struct CLIGitClient: PlaybookGitClient {
    func initializeRepository(at path: String) throws {
        let gitDirectory = URL(fileURLWithPath: path).appendingPathComponent(".git")
        guard !FileManager.default.fileExists(atPath: gitDirectory.path) else {
            return
        }

        _ = try CommandLineRunner.run(
            executable: "/usr/bin/env",
            arguments: ["git", "init", "-b", "main"],
            workingDirectory: URL(fileURLWithPath: path)
        )
    }

    func addRemoteOrigin(at path: String, remoteURL: String) throws {
        let workingDirectory = URL(fileURLWithPath: path)
        let currentOrigin = try? CommandLineRunner.run(
            executable: "/usr/bin/env",
            arguments: ["git", "remote", "get-url", "origin"],
            workingDirectory: workingDirectory
        ).trimmingCharacters(in: .whitespacesAndNewlines)

        if let currentOrigin, !currentOrigin.isEmpty {
            guard currentOrigin == remoteURL else {
                throw RuntimeError(message: "Git origin already points to \(currentOrigin), expected \(remoteURL).")
            }
            return
        }

        _ = try CommandLineRunner.run(
            executable: "/usr/bin/env",
            arguments: ["git", "remote", "add", "origin", remoteURL],
            workingDirectory: workingDirectory
        )
    }
}

struct GitHubCLIClient: PlaybookGitHubClient {
    func ensureRepository(named repositoryName: String, visibility: String, defaultBranch _: String) throws -> String {
        let user = try currentGitHubUser()
        if let existing = try existingRemoteURL(user: user, repositoryName: repositoryName) {
            return existing
        }
        return try createRemoteRepository(repositoryName: repositoryName, visibility: visibility)
    }
}

private extension GitHubCLIClient {
    func currentGitHubUser() throws -> String {
        try CommandLineRunner.run(
            executable: "/usr/bin/env",
            arguments: ["gh", "api", "user", "-q", ".login"],
            workingDirectory: nil
        ).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func existingRemoteURL(user: String, repositoryName: String) throws -> String? {
        guard !user.isEmpty else {
            return nil
        }

        let remoteURL = try? CommandLineRunner.run(
            executable: "/usr/bin/env",
            arguments: ["gh", "api", "repos/\(user)/\(repositoryName)", "-q", ".ssh_url"],
            workingDirectory: nil
        ).trimmingCharacters(in: .whitespacesAndNewlines)

        guard let remoteURL, !remoteURL.isEmpty else {
            return nil
        }
        return remoteURL
    }

    func createRemoteRepository(repositoryName: String, visibility: String) throws -> String {
        let privateFlag = visibility == "private" ? "true" : "false"
        return try CommandLineRunner.run(
            executable: "/usr/bin/env",
            arguments: [
                "gh", "api", "user/repos",
                "--method", "POST",
                "-f", "name=\(repositoryName)",
                "-f", "private=\(privateFlag)",
                "-f", "auto_init=false",
                "-q", ".ssh_url",
            ],
            workingDirectory: nil
        ).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private enum CommandLineRunner {
    static func run(executable: String, arguments: [String], workingDirectory: URL?) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.currentDirectoryURL = workingDirectory

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        try process.run()
        process.waitUntilExit()

        let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
        let errorData = stderr.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        let errorOutput = String(decoding: errorData, as: UTF8.self)

        guard process.terminationStatus == 0 else {
            let message = errorOutput.isEmpty ? output : errorOutput
            throw RuntimeError(message: message.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return output
    }
}
