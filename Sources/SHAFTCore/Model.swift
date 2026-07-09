import Foundation

public enum SHAFTCore {
    public static let version = "0.1.0"
}

public enum Outfit: CaseIterable {
    case crown, headphones, headband, wizardHat
}

public enum ClaudeModel: String, CaseIterable {
    case opus, sonnet, haiku, fable

    public var displayName: String {
        switch self {
        case .opus: return "Opus 4.8"
        case .sonnet: return "Sonnet 5"
        case .haiku: return "Haiku 4.5"
        case .fable: return "Fable 5"
        }
    }

    // Argument passed to `/model`. Verify aliases against the installed
    // Claude Code during Task 10; adjust here if they differ.
    public var modelArg: String {
        switch self {
        case .opus: return "opus"
        case .sonnet: return "sonnet"
        case .haiku: return "haiku"
        case .fable: return "claude-fable-5"
        }
    }

    public var outfit: Outfit {
        switch self {
        case .opus: return .crown
        case .sonnet: return .headphones
        case .haiku: return .headband
        case .fable: return .wizardHat
        }
    }
}

public enum Mood { case fresh, focused, tired, asleep }

extension Mood {
    public init(usageFraction f: Double) {
        switch f {
        case ..<0.5: self = .fresh
        case ..<0.8: self = .focused
        case ..<1.0: self = .tired
        default: self = .asleep
        }
    }
}
