//
// PhaxioCountry.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



open class PhaxioCountry: Codable {

    public var name: String?
    public var alpha2: String?
    public var countryCode: Int?
    public var pricePerPage: Int?
    public var sendSupport: String?
    public var receiveSupport: String?


    
    public init(name: String?, alpha2: String?, countryCode: Int?, pricePerPage: Int?, sendSupport: String?, receiveSupport: String?) {
        self.name = name
        self.alpha2 = alpha2
        self.countryCode = countryCode
        self.pricePerPage = pricePerPage
        self.sendSupport = sendSupport
        self.receiveSupport = receiveSupport
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(name, forKey: "name")
        try container.encodeIfPresent(alpha2, forKey: "alpha2")
        try container.encodeIfPresent(countryCode, forKey: "country_code")
        try container.encodeIfPresent(pricePerPage, forKey: "price_per_page")
        try container.encodeIfPresent(sendSupport, forKey: "send_support")
        try container.encodeIfPresent(receiveSupport, forKey: "receive_support")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        name = try container.decodeIfPresent(String.self, forKey: "name")
        alpha2 = try container.decodeIfPresent(String.self, forKey: "alpha2")
        countryCode = try container.decodeIfPresent(Int.self, forKey: "country_code")
        pricePerPage = try container.decodeIfPresent(Int.self, forKey: "price_per_page")
        sendSupport = try container.decodeIfPresent(String.self, forKey: "send_support")
        receiveSupport = try container.decodeIfPresent(String.self, forKey: "receive_support")
    }
}

