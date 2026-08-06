import Foundation

/// Canonical enum values used by App Store privacy nutrition labels.
///
/// Apple does not publish the privacy-label vocabulary in the App Store Connect
/// OpenAPI specification, and the endpoints that manage privacy details are not
/// part of the public REST API. These tables are therefore reference data only:
/// they describe the values App Store Connect accepts in its web UI so callers
/// can plan and review a privacy declaration. Nothing here performs a network
/// request or writes to App Store Connect.
enum AppPrivacyReferenceData {
    /// A privacy data type and the App Store group it is displayed under.
    struct Category: Sendable, Equatable {
        let id: String
        let group: String
    }

    /// A declared reason an app collects a data type.
    struct Purpose: Sendable, Equatable {
        let id: String
        let summary: String
    }

    /// How collected data relates to the user's identity.
    struct Protection: Sendable, Equatable {
        let id: String
        let summary: String
    }

    static let categories: [Category] = [
        Category(id: "NAME", group: "Contact Info"),
        Category(id: "EMAIL_ADDRESS", group: "Contact Info"),
        Category(id: "PHONE_NUMBER", group: "Contact Info"),
        Category(id: "PHYSICAL_ADDRESS", group: "Contact Info"),
        Category(id: "OTHER_CONTACT_INFO", group: "Contact Info"),
        Category(id: "HEALTH", group: "Health & Fitness"),
        Category(id: "FITNESS", group: "Health & Fitness"),
        Category(id: "PAYMENT_INFORMATION", group: "Financial Info"),
        Category(id: "CREDIT_AND_FRAUD", group: "Financial Info"),
        Category(id: "OTHER_FINANCIAL_INFO", group: "Financial Info"),
        Category(id: "PRECISE_LOCATION", group: "Location"),
        Category(id: "COARSE_LOCATION", group: "Location"),
        Category(id: "SENSITIVE_INFO", group: "Sensitive Info"),
        Category(id: "CONTACTS", group: "Contacts"),
        Category(id: "EMAILS_OR_TEXT_MESSAGES", group: "User Content"),
        Category(id: "PHOTOS_OR_VIDEOS", group: "User Content"),
        Category(id: "AUDIO", group: "User Content"),
        Category(id: "GAMEPLAY_CONTENT", group: "User Content"),
        Category(id: "CUSTOMER_SUPPORT", group: "User Content"),
        Category(id: "OTHER_USER_CONTENT", group: "User Content"),
        Category(id: "BROWSING_HISTORY", group: "Browsing History"),
        Category(id: "SEARCH_HISTORY", group: "Search History"),
        Category(id: "USER_ID", group: "Identifiers"),
        Category(id: "DEVICE_ID", group: "Identifiers"),
        Category(id: "PURCHASE_HISTORY", group: "Purchases"),
        Category(id: "PRODUCT_INTERACTION", group: "Usage Data"),
        Category(id: "ADVERTISING_DATA", group: "Usage Data"),
        Category(id: "OTHER_USAGE_DATA", group: "Usage Data"),
        Category(id: "CRASH_DATA", group: "Diagnostics"),
        Category(id: "PERFORMANCE_DATA", group: "Diagnostics"),
        Category(id: "OTHER_DIAGNOSTIC_DATA", group: "Diagnostics"),
        Category(id: "ENVIRONMENT_SCANNING", group: "Surroundings"),
        Category(id: "HANDS", group: "Body"),
        Category(id: "HEAD", group: "Body"),
        Category(id: "OTHER_DATA", group: "Other Data")
    ]

    static let purposes: [Purpose] = [
        Purpose(id: "THIRD_PARTY_ADVERTISING", summary: "Displaying third-party advertising, or sharing data with advertising networks."),
        Purpose(id: "DEVELOPERS_ADVERTISING", summary: "Displaying first-party advertising, or measuring the effectiveness of the developer's own advertising."),
        Purpose(id: "ANALYTICS", summary: "Evaluating user behavior, including how the app or its services are used."),
        Purpose(id: "PRODUCT_PERSONALIZATION", summary: "Customizing what the user sees, such as a personalized list of recommendations."),
        Purpose(id: "APP_FUNCTIONALITY", summary: "Enabling app features such as authentication, security, fraud prevention, or customer support."),
        Purpose(id: "OTHER_PURPOSES", summary: "Any purpose not covered by the other categories.")
    ]

    static let protections: [Protection] = [
        Protection(id: "DATA_LINKED_TO_YOU", summary: "Collected and tied to the user's identity."),
        Protection(id: "DATA_NOT_LINKED_TO_YOU", summary: "Collected but not tied to the user's identity."),
        Protection(id: "DATA_USED_TO_TRACK_YOU", summary: "Linked with third-party data for advertising, or shared with a data broker."),
        Protection(id: "DATA_NOT_COLLECTED", summary: "Declares that the app collects no data of this kind. Declared without a category or purpose.")
    ]
}
