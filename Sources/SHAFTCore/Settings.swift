import Foundation

// Reads the model configured in Claude Code's settings.json — a reliable,
// session-independent signal for the outfit that reflects `/model` changes,
// unlike scraping a live tmux pane (which only sees a Claude-in-tmux).
public enum SettingsModel {
    static let defaultPath =
        ("~/.claude/settings.json" as NSString).expandingTildeInPath

    // The configured model mapped to a ClaudeModel; nil if the file is
    // unreadable or the value isn't recognized. `path` is injectable.
    public static func current(path: String? = nil) -> ClaudeModel? {
        let p = path ?? defaultPath
        guard let data = FileManager.default.contents(atPath: p),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let raw = (obj as? [String: Any])?["model"] as? String
        else { return nil }
        return model(from: raw)
    }

    // Match a model-name substring (opus/sonnet/haiku/fable),
    // case-insensitive — tolerates ids like "claude-opus-4-8" or "opus".
    public static func model(from raw: String) -> ClaudeModel? {
        let s = raw.lowercased()
        return ClaudeModel.allCases.first { s.contains($0.rawValue) }
    }
}
