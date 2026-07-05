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

    public init(isEnabled: Bool, monthlyLimit: Double?, usedCredits: Double?,
                utilization: Double?, currency: String?) {
        self.isEnabled = isEnabled
        self.monthlyLimit = monthlyLimit
        self.usedCredits = usedCredits
        self.utilization = utilization
        self.currency = currency
    }
}

public struct Money: Decodable {
    public let amountMinor: Int
    public let currency: String
    public let exponent: Int
    public init(amountMinor: Int, currency: String, exponent: Int) {
        self.amountMinor = amountMinor; self.currency = currency
        self.exponent = exponent
    }
}

public struct Spend: Decodable {
    public let used: Money?
    public let limit: Money?
    public let enabled: Bool
    public init(used: Money?, limit: Money?, enabled: Bool) {
        self.used = used; self.limit = limit; self.enabled = enabled
    }
}

public struct UsageSnapshot: Decodable {
    public let fiveHour: Window?
    public let sevenDay: Window?
    public let extraUsage: ExtraUsage?
    public let spend: Spend?

    public init(fiveHour: Window?, sevenDay: Window?,
                extraUsage: ExtraUsage?, spend: Spend? = nil) {
        self.fiveHour = fiveHour
        self.sevenDay = sevenDay
        self.extraUsage = extraUsage
        self.spend = spend
    }

    public var worstFraction: Double {
        max(fiveHour?.utilization ?? 0, sevenDay?.utilization ?? 0) / 100.0
    }

    public static func decode(_ data: Data) throws -> UsageSnapshot {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return try d.decode(UsageSnapshot.self, from: data)
    }
}
