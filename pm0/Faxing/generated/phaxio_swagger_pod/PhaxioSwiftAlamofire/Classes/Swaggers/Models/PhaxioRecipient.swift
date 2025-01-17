//
// PhaxioRecipient.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation



open class PhaxioRecipient: Codable {

    public var phoneNumber: String?
    public var status: String?
    public var completedAt: Date?
    public var bitrate: Int?
    public var resolution: Int?
    public var errorType: String?
    public var errorMessage: String?
    public var errorId: Int?


    
    public init(phoneNumber: String?, status: String?, completedAt: Date?, bitrate: Int?, resolution: Int?, errorType: String?, errorMessage: String?, errorId: Int?) {
        self.phoneNumber = phoneNumber
        self.status = status
        self.completedAt = completedAt
        self.bitrate = bitrate
        self.resolution = resolution
        self.errorType = errorType
        self.errorMessage = errorMessage
        self.errorId = errorId
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(phoneNumber, forKey: "phone_number")
        try container.encodeIfPresent(status, forKey: "status")
        try container.encodeIfPresent(completedAt, forKey: "completed_at")
        try container.encodeIfPresent(bitrate, forKey: "bitrate")
        try container.encodeIfPresent(resolution, forKey: "resolution")
        try container.encodeIfPresent(errorType, forKey: "error_type")
        try container.encodeIfPresent(errorMessage, forKey: "error_message")
        try container.encodeIfPresent(errorId, forKey: "error_id")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        phoneNumber = try container.decodeIfPresent(String.self, forKey: "phone_number")
        status = try container.decodeIfPresent(String.self, forKey: "status")
        completedAt = try container.decodeIfPresent(Date.self, forKey: "completed_at")
        bitrate = try container.decodeIfPresent(Int.self, forKey: "bitrate")
        resolution = try container.decodeIfPresent(Int.self, forKey: "resolution")
        errorType = try container.decodeIfPresent(String.self, forKey: "error_type")
        errorMessage = try container.decodeIfPresent(String.self, forKey: "error_message")
        errorId = try container.decodeIfPresent(Int.self, forKey: "error_id")
    }
}

