import Foundation
public struct CommandResult {
    public let stdout: String; public let stderr: String; public let code: Int32
    public init(stdout: String, stderr: String, code: Int32) {
        self.stdout = stdout; self.stderr = stderr; self.code = code
    }
}
public protocol CommandRunner {
    func run(_ path: String, _ args: [String]) -> CommandResult
}
public struct ProcessCommandRunner: CommandRunner {
    public init() {}
    public func run(_ path: String, _ args: [String]) -> CommandResult {
        let p = Process(); p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        let out = Pipe(); let err = Pipe()
        p.standardOutput = out; p.standardError = err
        do { try p.run() } catch {
            return CommandResult(stdout: "", stderr: "\(error)", code: -1)
        }
        p.waitUntilExit()
        func s(_ pipe: Pipe) -> String {
            String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(),
                   as: UTF8.self)
        }
        return CommandResult(stdout: s(out), stderr: s(err),
                             code: p.terminationStatus)
    }
}
