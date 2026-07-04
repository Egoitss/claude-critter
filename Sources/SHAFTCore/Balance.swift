import Foundation

public enum BalanceLine: Equatable {
    case overage(remaining: Double, limit: Double, currency: String)
    case hidden

    public static func resolve(_ s: UsageSnapshot) -> BalanceLine {
        guard let e = s.extraUsage, e.isEnabled,
              let limit = e.monthlyLimit, let used = e.usedCredits
        else { return .hidden }
        return .overage(remaining: max(0, limit - used), limit: limit,
                        currency: e.currency ?? "USD")
    }

    public var display: String? {
        guard case let .overage(rem, limit, cur) = self else { return nil }
        let s = Self.symbol(cur)
        return String(format: "%@%.2f left of %@%.2f", s, rem, s, limit)
    }

    static func symbol(_ code: String) -> String {
        switch code {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        default: return code + " "
        }
    }
}
