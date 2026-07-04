import Foundation

public struct Window: Decodable {
    public let utilization: Double
    public let resetsAt: Date?
}

public struct ExtraUsage: Decodable {
    public let isEnabled: Bool
    public let monthlyLimit: Double?
    public let usedCredits: Double?
    public let utilization: Double?
    public let currency: String?
}

public struct UsageSnapshot: Decodable {
    public let fiveHour: Window?
    public let sevenDay: Window?
    public let extraUsage: ExtraUsage?

    public var worstFraction: Double {
        max(fiveHour?.utilization ?? 0, sevenDay?.utilization ?? 0)
    }

    public static func decode(_ data: Data) throws -> UsageSnapshot {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return try d.decode(UsageSnapshot.self, from: data)
    }
}
