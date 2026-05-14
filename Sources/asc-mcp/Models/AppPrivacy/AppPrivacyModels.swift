import Foundation

// MARK: - App Privacy (App Data Usages)
//
// App Store Connect's "App Privacy" (Privacy Nutrition Labels) is served by an
// internal "Iris" API at `appstoreconnect.apple.com/iris/v1/`. It is not part
// of the official documented REST API and historically requires Apple ID
// session authentication. JWT-based App Store Connect API keys are not
// officially supported for these endpoints; this MCP attempts them anyway and
// surfaces the API's error message when Apple rejects the call.

// MARK: - AppDataUsage

/// One row in the Privacy Nutrition Label — a (category, purpose, protection) tuple.
struct AppDataUsage: Codable, Sendable {
    let type: String
    let id: String
    let relationships: Relationships?

    struct Relationships: Codable, Sendable {
        let category: ResourceLink?
        let purpose: ResourceLink?
        let dataProtection: ResourceLink?
        let grouping: ResourceLink?
    }

    struct ResourceLink: Codable, Sendable {
        let data: ResourceRef?
        struct ResourceRef: Codable, Sendable {
            let type: String
            let id: String
        }
    }
}

struct AppDataUsagesListResponse: Codable, Sendable {
    let data: [AppDataUsage]
    let included: [JSONValue]?
    let links: JSONValue?
}

struct AppDataUsageSingleResponse: Codable, Sendable {
    let data: AppDataUsage
    let included: [JSONValue]?
}

// MARK: - AppDataUsageCategory / Purpose / Protection

struct AppDataUsageCategory: Codable, Sendable {
    let type: String
    let id: String
    let attributes: AttributesPayload?
    let relationships: Relationships?

    struct AttributesPayload: Codable, Sendable {
        let deletable: Bool?
    }

    struct Relationships: Codable, Sendable {
        let grouping: AppDataUsage.ResourceLink?
    }
}

struct AppDataUsageCategoriesListResponse: Codable, Sendable {
    let data: [AppDataUsageCategory]
    let included: [JSONValue]?
}

struct AppDataUsagePurpose: Codable, Sendable {
    let type: String
    let id: String
}

struct AppDataUsagePurposesListResponse: Codable, Sendable {
    let data: [AppDataUsagePurpose]
}

struct AppDataUsageDataProtection: Codable, Sendable {
    let type: String
    let id: String
}

struct AppDataUsageDataProtectionsListResponse: Codable, Sendable {
    let data: [AppDataUsageDataProtection]
}

// MARK: - Publish State

struct AppDataUsagesPublishState: Codable, Sendable {
    let type: String
    let id: String
    let attributes: Attributes?

    struct Attributes: Codable, Sendable {
        let published: Bool?
        let lastPublished: String?
        let lastPublishedBy: String?
    }
}

struct AppDataUsagesPublishStateResponse: Codable, Sendable {
    let data: AppDataUsagesPublishState
}

// MARK: - Create / Update Requests

/// POST /iris/v1/appDataUsages
struct CreateAppDataUsageRequest: Codable, Sendable {
    let data: Body

    struct Body: Codable, Sendable {
        let type: String
        let relationships: Relationships
    }

    struct Relationships: Codable, Sendable {
        let app: RelationshipData
        let category: RelationshipData?
        let purpose: RelationshipData?
        let dataProtection: RelationshipData?
    }

    init(
        appId: String,
        categoryId: String?,
        purposeId: String?,
        dataProtectionId: String?
    ) {
        let category = categoryId.map {
            RelationshipData(data: .init(type: "appDataUsageCategories", id: $0))
        }
        let purpose = purposeId.map {
            RelationshipData(data: .init(type: "appDataUsagePurposes", id: $0))
        }
        let dataProtection = dataProtectionId.map {
            RelationshipData(data: .init(type: "appDataUsageDataProtections", id: $0))
        }

        let rels = Relationships(
            app: RelationshipData(data: .init(type: "apps", id: appId)),
            category: category,
            purpose: purpose,
            dataProtection: dataProtection
        )

        self.data = Body(type: "appDataUsages", relationships: rels)
    }
}

/// PATCH /iris/v1/appDataUsagesPublishState/{id}
struct UpdateAppDataUsagesPublishStateRequest: Codable, Sendable {
    let data: Body

    struct Body: Codable, Sendable {
        let type: String
        let id: String
        let attributes: Attributes
    }

    struct Attributes: Codable, Sendable {
        let published: Bool
    }

    init(id: String, published: Bool) {
        self.data = Body(
            type: "appDataUsagesPublishState",
            id: id,
            attributes: Attributes(published: published)
        )
    }
}

// MARK: - Static Enums (from fastlane spaceship + Apple App Privacy docs)

enum AppPrivacyStaticEnums {
    /// 34 known categories (including newer visionOS-era additions).
    static let categories: [String] = [
        // Contact Info
        "NAME", "EMAIL_ADDRESS", "PHONE_NUMBER", "PHYSICAL_ADDRESS", "OTHER_CONTACT_INFO",
        // Health & Fitness
        "HEALTH", "FITNESS",
        // Financial Info
        "PAYMENT_INFORMATION", "CREDIT_AND_FRAUD", "OTHER_FINANCIAL_INFO",
        // Location
        "PRECISE_LOCATION", "COARSE_LOCATION",
        // Sensitive Info
        "SENSITIVE_INFO",
        // Contacts
        "CONTACTS",
        // User Content
        "EMAILS_OR_TEXT_MESSAGES", "PHOTOS_OR_VIDEOS", "AUDIO", "GAMEPLAY_CONTENT",
        "CUSTOMER_SUPPORT", "OTHER_USER_CONTENT",
        // Browsing / Search History
        "BROWSING_HISTORY", "SEARCH_HISTORY",
        // Identifiers
        "USER_ID", "DEVICE_ID",
        // Purchases
        "PURCHASE_HISTORY",
        // Usage Data
        "PRODUCT_INTERACTION", "ADVERTISING_DATA", "OTHER_USAGE_DATA",
        // Diagnostics
        "CRASH_DATA", "PERFORMANCE_DATA", "OTHER_DIAGNOSTIC_DATA",
        // Surroundings / Body (visionOS-era; documented by Apple, not present in fastlane source)
        "ENVIRONMENT_SCANNING", "HANDS", "HEAD",
        // Other
        "OTHER_DATA"
    ]

    static let purposes: [String] = [
        "THIRD_PARTY_ADVERTISING",
        "DEVELOPERS_ADVERTISING",
        "ANALYTICS",
        "PRODUCT_PERSONALIZATION",
        "APP_FUNCTIONALITY",
        "OTHER_PURPOSES"
    ]

    static let dataProtections: [String] = [
        "DATA_LINKED_TO_YOU",
        "DATA_NOT_LINKED_TO_YOU",
        "DATA_USED_TO_TRACK_YOU",
        "DATA_NOT_COLLECTED"
    ]
}
