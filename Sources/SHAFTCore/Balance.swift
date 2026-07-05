import Foundation

public enum BalanceLine: Equatable {
    case overage(remaining: Double, limit: Double, currency: String)
    case hidden

    public static func resolve(_ s: UsageSnapshot) -> BalanceLine {
        guard let sp = s.spend, sp.enabled,
              let limitM = sp.limit, let usedM = sp.used
        else { return .hidden }
        let limit = value(limitM)
        let used = value(usedM)
        return .overage(remaining: max(0, limit - used), limit: limit,
                        currency: limitM.currency)
    }

    static func value(_ m: Money) -> Double {
        Double(m.amountMinor) / pow(10, Double(m.exponent))
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
