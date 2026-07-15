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
