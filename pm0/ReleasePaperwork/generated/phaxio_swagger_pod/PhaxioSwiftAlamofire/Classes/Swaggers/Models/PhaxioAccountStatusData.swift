//
// PhaxioAccountStatusData.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



open class PhaxioAccountStatusData: Codable {

    public var balance: Int?
    public var faxesToday: Int?
    public var faxesThisMonth: Int?


    
    public init(balance: Int?, faxesToday: Int?, faxesThisMonth: Int?) {
        self.balance = balance
        self.faxesToday = faxesToday
        self.faxesThisMonth = faxesThisMonth
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(balance, forKey: "balance")
        try container.encodeIfPresent(faxesToday, forKey: "faxes_today")
        try container.encodeIfPresent(faxesThisMonth, forKey: "faxes_this_month")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        balance = try container.decodeIfPresent(Int.self, forKey: "balance")
        faxesToday = try container.decodeIfPresent(Int.self, forKey: "faxes_today")
        faxesThisMonth = try container.decodeIfPresent(Int.self, forKey: "faxes_this_month")
    }
}
