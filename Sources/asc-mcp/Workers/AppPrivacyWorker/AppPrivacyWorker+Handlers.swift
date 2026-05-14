//
//  AppPrivacyWorker+Handlers.swift
//  asc-mcp
//

import Foundation
import MCP

extension AppPrivacyWorker {

    // MARK: - Helpers

    /// Wraps an Iris API call. If Apple rejects JWT auth (401/403) or the
    /// endpoint is unreachable, augments the error message with the known
    /// limitation so users understand they may need to fall back to the web UI.
    private func formatIrisError(_ error: Error) -> String {
        let base = error.localizedDescription
        return "\(base). NOTE: App Privacy uses Apple's unofficial Iris API. JWT-based App Store Connect API keys may not be supported — Apple's official guidance says to use the web App Store Connect UI. If you're seeing 401/403, this is the expected fallback path."
    }

    // MARK: - Enum readers

    /// Lists all known App Privacy data categories.
    /// - Returns: JSON with a static category list, plus optional live data if the Iris API call succeeds.
    func listCategories(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        var liveData: Any? = nil
        var liveError: String? = nil

        do {
            let response = try await httpClient.get(
                "/iris/v1/appDataUsageCategories",
                parameters: ["limit": "200"],
                as: AppDataUsageCategoriesListResponse.self
            )
            liveData = response.data.map { ["id": $0.id, "type": $0.type] }
        } catch {
            liveError = formatIrisError(error)
        }

        var result: [String: Any] = [
            "static_categories": AppPrivacyStaticEnums.categories,
            "count_static": AppPrivacyStaticEnums.categories.count
        ]
        if let liveData {
            result["live_categories"] = liveData
        }
        if let liveError {
            result["live_api_error"] = liveError
            result["note"] = "Use static_categories for input; live_api_error is informational."
        }
        return MCPResult.jsonObject(result)
    }

    /// Lists App Privacy data usage purposes.
    func listPurposes(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        var liveData: Any? = nil
        var liveError: String? = nil

        do {
            let response = try await httpClient.get(
                "/iris/v1/appDataUsagePurposes",
                parameters: ["limit": "200"],
                as: AppDataUsagePurposesListResponse.self
            )
            liveData = response.data.map { ["id": $0.id, "type": $0.type] }
        } catch {
            liveError = formatIrisError(error)
        }

        var result: [String: Any] = [
            "static_purposes": AppPrivacyStaticEnums.purposes,
            "count_static": AppPrivacyStaticEnums.purposes.count
        ]
        if let liveData {
            result["live_purposes"] = liveData
        }
        if let liveError {
            result["live_api_error"] = liveError
        }
        return MCPResult.jsonObject(result)
    }

    /// Lists App Privacy data protection levels.
    func listProtections(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        let result: [String: Any] = [
            "static_protections": AppPrivacyStaticEnums.dataProtections,
            "count": AppPrivacyStaticEnums.dataProtections.count,
            "note": "These four values are stable enums in Apple's privacy data model."
        ]
        return MCPResult.jsonObject(result)
    }

    // MARK: - Per-app usages

    /// List App Privacy entries for an app.
    func listUsages(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        guard let arguments = params.arguments,
              let appId = arguments["app_id"]?.stringValue else {
            return CallTool.Result(
                content: [MCPContent.text("Error: Required parameter 'app_id' is missing")],
                isError: true
            )
        }

        let limit: String
        if let value = arguments["limit"]?.intValue {
            limit = String(value)
        } else {
            limit = "500"
        }

        do {
            let response = try await httpClient.get(
                "/iris/v1/apps/\(appId)/dataUsages",
                parameters: [
                    "limit": limit,
                    "include": "category,purpose,dataProtection,grouping"
                ],
                as: AppDataUsagesListResponse.self
            )

            let usages: [[String: Any]] = response.data.map { usage in
                var item: [String: Any] = [
                    "id": usage.id,
                    "type": usage.type
                ]
                if let category = usage.relationships?.category?.data {
                    item["category_id"] = category.id
                }
                if let purpose = usage.relationships?.purpose?.data {
                    item["purpose_id"] = purpose.id
                }
                if let protection = usage.relationships?.dataProtection?.data {
                    item["data_protection_id"] = protection.id
                }
                if let grouping = usage.relationships?.grouping?.data {
                    item["grouping_id"] = grouping.id
                }
                return item
            }

            let result: [String: Any] = [
                "app_id": appId,
                "count": usages.count,
                "usages": usages
            ]
            return MCPResult.jsonObject(result)

        } catch {
            return CallTool.Result(
                content: [MCPContent.text("Error: Failed to list app privacy usages: \(formatIrisError(error))")],
                isError: true
            )
        }
    }

    /// Get publish state for an app's privacy details.
    func getPublishState(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        guard let arguments = params.arguments,
              let appId = arguments["app_id"]?.stringValue else {
            return CallTool.Result(
                content: [MCPContent.text("Error: Required parameter 'app_id' is missing")],
                isError: true
            )
        }

        do {
            let response = try await httpClient.get(
                "/iris/v1/apps/\(appId)/dataUsagePublishState",
                as: AppDataUsagesPublishStateResponse.self
            )

            var result: [String: Any] = [
                "app_id": appId,
                "publish_state_id": response.data.id,
                "type": response.data.type
            ]
            if let attrs = response.data.attributes {
                if let published = attrs.published { result["published"] = published }
                if let lastPublished = attrs.lastPublished { result["last_published"] = lastPublished }
                if let lastPublishedBy = attrs.lastPublishedBy { result["last_published_by"] = lastPublishedBy }
            }
            return MCPResult.jsonObject(result)

        } catch {
            return CallTool.Result(
                content: [MCPContent.text("Error: Failed to get publish state: \(formatIrisError(error))")],
                isError: true
            )
        }
    }

    // MARK: - Mutations

    /// Create one App Privacy entry.
    func createUsage(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        guard let arguments = params.arguments,
              let appId = arguments["app_id"]?.stringValue else {
            return CallTool.Result(
                content: [MCPContent.text("Error: Required parameter 'app_id' is missing")],
                isError: true
            )
        }
        guard let dataProtectionId = arguments["data_protection_id"]?.stringValue else {
            return CallTool.Result(
                content: [MCPContent.text("Error: Required parameter 'data_protection_id' is missing")],
                isError: true
            )
        }

        let categoryId = arguments["category_id"]?.stringValue
        let purposeId = arguments["purpose_id"]?.stringValue

        // Sanity check: DATA_NOT_COLLECTED implies no category/purpose.
        if dataProtectionId == "DATA_NOT_COLLECTED",
           (categoryId != nil || purposeId != nil) {
            return CallTool.Result(
                content: [MCPContent.text("Error: DATA_NOT_COLLECTED entries must not include category_id or purpose_id.")],
                isError: true
            )
        }

        let request = CreateAppDataUsageRequest(
            appId: appId,
            categoryId: categoryId,
            purposeId: purposeId,
            dataProtectionId: dataProtectionId
        )

        do {
            let response = try await httpClient.post(
                "/iris/v1/appDataUsages",
                body: request,
                as: AppDataUsageSingleResponse.self
            )

            var result: [String: Any] = [
                "success": true,
                "usage_id": response.data.id,
                "type": response.data.type,
                "app_id": appId,
                "data_protection_id": dataProtectionId
            ]
            if let categoryId { result["category_id"] = categoryId }
            if let purposeId { result["purpose_id"] = purposeId }
            return MCPResult.jsonObject(result)

        } catch {
            return CallTool.Result(
                content: [MCPContent.text("Error: Failed to create app privacy usage: \(formatIrisError(error))")],
                isError: true
            )
        }
    }

    /// Delete an App Privacy entry by id.
    func deleteUsage(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        guard let arguments = params.arguments,
              let usageId = arguments["usage_id"]?.stringValue else {
            return CallTool.Result(
                content: [MCPContent.text("Error: Required parameter 'usage_id' is missing")],
                isError: true
            )
        }

        do {
            _ = try await httpClient.delete("/iris/v1/appDataUsages/\(usageId)")
            let result: [String: Any] = [
                "success": true,
                "deleted_usage_id": usageId
            ]
            return MCPResult.jsonObject(result)

        } catch {
            return CallTool.Result(
                content: [MCPContent.text("Error: Failed to delete app privacy usage: \(formatIrisError(error))")],
                isError: true
            )
        }
    }

    /// Publish the current draft App Privacy details.
    func publish(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        return try await setPublished(params, published: true)
    }

    /// Mark App Privacy details as unpublished.
    func unpublish(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        return try await setPublished(params, published: false)
    }

    private func setPublished(_ params: CallTool.Parameters, published: Bool) async throws -> CallTool.Result {
        guard let arguments = params.arguments,
              let appId = arguments["app_id"]?.stringValue else {
            return CallTool.Result(
                content: [MCPContent.text("Error: Required parameter 'app_id' is missing")],
                isError: true
            )
        }

        do {
            // Step 1: resolve publish state ID
            let stateResponse = try await httpClient.get(
                "/iris/v1/apps/\(appId)/dataUsagePublishState",
                as: AppDataUsagesPublishStateResponse.self
            )
            let publishStateId = stateResponse.data.id

            // Step 2: PATCH it
            let request = UpdateAppDataUsagesPublishStateRequest(
                id: publishStateId,
                published: published
            )
            let patchResponse = try await httpClient.patch(
                "/iris/v1/appDataUsagesPublishState/\(publishStateId)",
                body: request,
                as: AppDataUsagesPublishStateResponse.self
            )

            var result: [String: Any] = [
                "success": true,
                "app_id": appId,
                "publish_state_id": patchResponse.data.id,
                "requested_published": published
            ]
            if let attrs = patchResponse.data.attributes,
               let actualPublished = attrs.published {
                result["actual_published"] = actualPublished
            }
            return MCPResult.jsonObject(result)

        } catch {
            return CallTool.Result(
                content: [MCPContent.text("Error: Failed to \(published ? "publish" : "unpublish") app privacy: \(formatIrisError(error))")],
                isError: true
            )
        }
    }
}
