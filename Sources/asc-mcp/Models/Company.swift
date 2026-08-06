import Foundation

/// Model for company configuration
public struct Company: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let keyID: String
    /// Issuer ID of the App Store Connect API key.
    /// `nil` marks an Individual API Key, which Apple issues without an issuer ID.
    public let issuerID: String?
    public let privateKeyPath: String
    /// Private key content (PEM string). If set, takes priority over `privateKeyPath`.
    public let privateKeyContent: String?
    /// Vendor number for sales/financial reports (found in ASC Sales and Trends)
    public let vendorNumber: String?

    /// True when this company authenticates with an Individual API Key (no issuer ID).
    /// Individual keys are scoped to one user and cannot reach Provisioning,
    /// Sales and Finance, or notarytool endpoints.
    public var isIndividualKey: Bool { issuerID == nil }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case keyID = "key_id"
        case issuerID = "issuer_id"
        case privateKeyPath = "key_path"
        case privateKeyContent = "key_content"
        case vendorNumber = "vendor_number"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        keyID = try container.decode(String.self, forKey: .keyID)
        issuerID = try container.decodeIfPresent(String.self, forKey: .issuerID)
        privateKeyPath = try container.decodeIfPresent(String.self, forKey: .privateKeyPath) ?? ""
        privateKeyContent = try container.decodeIfPresent(String.self, forKey: .privateKeyContent)
        vendorNumber = try container.decodeIfPresent(String.self, forKey: .vendorNumber)
    }

    public init(
        id: String, name: String,
        keyID: String, issuerID: String? = nil,
        privateKeyPath: String = "",
        privateKeyContent: String? = nil,
        vendorNumber: String? = nil
    ) {
        self.id = id
        self.name = name
        self.keyID = keyID
        self.issuerID = issuerID
        self.privateKeyPath = privateKeyPath
        self.privateKeyContent = privateKeyContent
        self.vendorNumber = vendorNumber
    }

    /// Omits `issuer_id` entirely for Individual API Keys instead of writing an explicit null,
    /// so an encoded company round-trips back through `init(from:)` unchanged.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(keyID, forKey: .keyID)
        try container.encodeIfPresent(issuerID, forKey: .issuerID)
        try container.encode(privateKeyPath, forKey: .privateKeyPath)
        try container.encodeIfPresent(privateKeyContent, forKey: .privateKeyContent)
        try container.encodeIfPresent(vendorNumber, forKey: .vendorNumber)
    }
}

/// Container for all companies
public struct CompaniesConfig: Codable, Sendable {
    public let defaultURL: String
    public let companies: [Company]

    enum CodingKeys: String, CodingKey {
        case defaultURL = "defaultURL"
        case companies
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultURL = try container.decodeIfPresent(String.self, forKey: .defaultURL)
            ?? "https://api.appstoreconnect.apple.com"
        companies = try container.decode([Company].self, forKey: .companies)
    }

    public init(companies: [Company], defaultURL: String = "https://api.appstoreconnect.apple.com") {
        self.companies = companies
        self.defaultURL = defaultURL
    }
}
