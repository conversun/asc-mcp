import Foundation

// MARK: - Sandbox Tester Models

/// Sandbox testers list response
public struct ASCSandboxTestersResponse: Codable, Sendable {
    public let data: [ASCSandboxTester]
    public let links: ASCPagedDocumentLinks?
}

/// Sandbox tester single response
public struct ASCSandboxTesterResponse: Codable, Sendable {
    public let data: ASCSandboxTester
}

/// Sandbox tester resource
public struct ASCSandboxTester: Codable, Sendable {
    public let type: String
    public let id: String
    public let attributes: SandboxTesterAttributes
}

/// Sandbox tester attributes
public struct SandboxTesterAttributes: Codable, Sendable {
    public let firstName: String?
    public let lastName: String?
    public let acAccountName: String?
    public let territory: String?
    public let applePayCompatible: Bool?
    public let interruptPurchases: Bool?
    public let subscriptionRenewalRate: String?
}

// MARK: - Sandbox Tester Request Models

/// Update sandbox tester request
public struct UpdateSandboxTesterRequest: Codable, Sendable {
    public let data: UpdateData

    public struct UpdateData: Codable, Sendable {
        public var type: String = "sandboxTesters"
        public let id: String
        public let attributes: Attributes
    }

    public struct Attributes: Codable, Sendable {
        public let territory: String?
        public let interruptPurchases: Bool?
        public let subscriptionRenewalRate: String?
    }
}

/// Clear purchase history request
public struct ClearPurchaseHistoryRequest: Codable, Sendable {
    public let data: RequestData

    public struct RequestData: Codable, Sendable {
        public var type: String = "sandboxTestersClearPurchaseHistoryRequest"
        public let relationships: Relationships
    }

    public struct Relationships: Codable, Sendable {
        public let sandboxTesters: SandboxTestersRelationship
    }

    public struct SandboxTestersRelationship: Codable, Sendable {
        public let data: [ASCResourceIdentifier]
    }
}

/// Create sandbox tester request (undocumented `POST /v1/sandboxTesters`).
///
/// Apple's official documentation says sandbox testers can only be created via
/// the App Store Connect web UI, but the underlying REST endpoint exists and
/// is used by fastlane's spaceship ConnectAPI client with JWT auth. We follow
/// the same pattern. If Apple closes the endpoint, calls return 4xx and the
/// caller is told to fall back to the web UI.
public struct CreateSandboxTesterRequest: Codable, Sendable {
    public let data: CreateData

    public struct CreateData: Codable, Sendable {
        public var type: String = "sandboxTesters"
        public let attributes: Attributes
    }

    public struct Attributes: Codable, Sendable {
        public let firstName: String
        public let lastName: String
        public let email: String
        public let password: String
        public let confirmPassword: String
        public let secretQuestion: String?
        public let secretAnswer: String?
        public let birthDate: String?
        public let appStoreTerritory: String?
    }
}
