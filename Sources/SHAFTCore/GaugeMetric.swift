import Foundation

/// Which usage figure the pet gauge shows. Right-clicking the gauge
/// strip cycles session -> weekly -> credits -> session; `session`
/// is the launch default. `credits` is skipped while extra usage is
/// off, so the cycle never lands on an empty mode.
public enum GaugeMetric: Equatable {
    case session   // 5-hour window, remaining %
    case weekly    // 7-day window, remaining %
    case credits   // extra-usage dollars remaining

    /// Next metric in the cycle. Pass `creditsAvailable: false`
    /// when the snapshot has no enabled spend block.
    public func next(creditsAvailable: Bool) -> GaugeMetric {
        switch self {
        case .session: return .weekly
        case .weekly: return creditsAvailable ? .credits : .session
        case .credits: return .session
        }
    }
}

/// The icon slot drawn left of the gauge label.
public enum GaugeIcon: Equatable { case heart, weekly, dollar }

/// One resolved gauge display: icon, label text, and whether the
/// underlying figure is known (unknown renders dim, as "--").
public struct GaugeReading: Equatable {
    public let icon: GaugeIcon
    public let text: String
    public let known: Bool

    /// Memberwise init, public for the renderer and tests.
    public init(icon: GaugeIcon, text: String, known: Bool) {
        self.icon = icon; self.text = text; self.known = known
    }

    /// Maps a metric + latest snapshot to what the gauge draws.
    /// Percent modes show remaining budget (100 - used); credits
    /// shows remaining dollars, dropping cents from $100 up so the
    /// label fits the 128px strip.
    public static func resolve(_ metric: GaugeMetric,
                               snapshot: UsageSnapshot?)
        -> GaugeReading {
        switch metric {
        case .session:
            return percent(.heart, snapshot?.fiveHour)
        case .weekly:
            return percent(.weekly, snapshot?.sevenDay)
        case .credits:
            return credits(snapshot)
        }
    }

    /// Remaining-% reading for one usage window, or unknown.
    private static func percent(_ icon: GaugeIcon,
                                _ window: Window?) -> GaugeReading {
        guard let w = window else {
            return GaugeReading(icon: icon, text: "--", known: false)
        }
        let left = max(0, min(1, 1 - w.utilization / 100))
        let p = Int((left * 100).rounded())
        return GaugeReading(icon: icon, text: "\(p)%", known: true)
    }

    /// Remaining extra-usage dollars, or unknown when spend is off.
    private static func credits(_ snapshot: UsageSnapshot?)
        -> GaugeReading {
        guard let s = snapshot,
              case let .overage(rem, _, _) = BalanceLine.resolve(s)
        else {
            return GaugeReading(icon: .dollar, text: "--",
                                known: false)
        }
        let text = rem < 100 ? String(format: "%.2f", rem)
                             : String(format: "%.0f", rem)
        return GaugeReading(icon: .dollar, text: text, known: true)
    }
}
