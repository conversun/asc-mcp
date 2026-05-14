//
//  AppPrivacyWorker.swift
//  asc-mcp
//
//  App Privacy (Privacy Nutrition Labels) management via the App Store Connect
//  Iris API.
//
//  IMPORTANT: The endpoints used here live on `appstoreconnect.apple.com/iris/v1/`
//  (NOT `api.appstoreconnect.apple.com/v1/`). Apple has historically required
//  Apple ID session auth for this API and explicitly documents that App Store
//  Connect API Keys "cannot be used". This worker still attempts JWT auth
//  against the same JWTService — if Apple rejects it (401/403), tools surface a
//  clear error message so callers can fall back to the App Store Connect web UI.
//

import Foundation
import MCP

/// AppPrivacyWorker manages App Privacy (Privacy Nutrition Labels) entries.
public final class AppPrivacyWorker: Sendable {
    /// HTTPClient targeting the Iris host (`https://appstoreconnect.apple.com`).
    /// Endpoints are passed as `/iris/v1/...`.
    let httpClient: HTTPClient

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    /// Builds an HTTPClient targeting the Iris host using the supplied JWT service.
    public static func makeIrisClient(jwtService: JWTService) async -> HTTPClient {
        await HTTPClient(
            jwtService: jwtService,
            baseURL: "https://appstoreconnect.apple.com"
        )
    }

    public func getTools() async -> [Tool] {
        return [
            listCategoriesTool(),
            listPurposesTool(),
            listProtectionsTool(),
            listUsagesTool(),
            getPublishStateTool(),
            createUsageTool(),
            deleteUsageTool(),
            publishTool(),
            unpublishTool()
        ]
    }

    public func handleTool(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        switch params.name {
        case "app_privacy_list_categories":
            return try await listCategories(params)
        case "app_privacy_list_purposes":
            return try await listPurposes(params)
        case "app_privacy_list_protections":
            return try await listProtections(params)
        case "app_privacy_list_usages":
            return try await listUsages(params)
        case "app_privacy_get_publish_state":
            return try await getPublishState(params)
        case "app_privacy_create_usage":
            return try await createUsage(params)
        case "app_privacy_delete_usage":
            return try await deleteUsage(params)
        case "app_privacy_publish":
            return try await publish(params)
        case "app_privacy_unpublish":
            return try await unpublish(params)
        default:
            throw MCPError.methodNotFound("Unknown tool: \(params.name)")
        }
    }
}
