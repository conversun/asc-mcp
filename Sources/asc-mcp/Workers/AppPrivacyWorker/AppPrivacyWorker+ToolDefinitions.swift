//
//  AppPrivacyWorker+ToolDefinitions.swift
//  asc-mcp
//

import Foundation
import MCP

extension AppPrivacyWorker {

    func listCategoriesTool() -> Tool {
        Tool(
            name: "app_privacy_list_categories",
            description: "List all App Privacy data categories (Contact Info, Health & Fitness, Location, etc.). Returns 34 known category IDs that are valid `category_id` values for app_privacy_create_usage. Also attempts a live API call to `/iris/v1/appDataUsageCategories`; if Apple rejects the JWT token, returns the static list with a warning.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([:])
            ])
        )
    }

    func listPurposesTool() -> Tool {
        Tool(
            name: "app_privacy_list_purposes",
            description: "List all App Privacy data usage purposes (Analytics, App Functionality, Third-Party Advertising, etc.). Returns 6 known purpose IDs.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([:])
            ])
        )
    }

    func listProtectionsTool() -> Tool {
        Tool(
            name: "app_privacy_list_protections",
            description: "List all App Privacy data protection levels: DATA_LINKED_TO_YOU, DATA_NOT_LINKED_TO_YOU, DATA_USED_TO_TRACK_YOU, DATA_NOT_COLLECTED.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([:])
            ])
        )
    }

    func listUsagesTool() -> Tool {
        Tool(
            name: "app_privacy_list_usages",
            description: "List the current App Privacy entries for an app. Each entry is one (category, purpose, protection) tuple. Calls `GET /iris/v1/apps/{appId}/dataUsages` on the unofficial Iris API; may fail if Apple rejects JWT auth.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "app_id": .object([
                        "type": .string("string"),
                        "description": .string("App ID")
                    ]),
                    "limit": .object([
                        "type": .string("integer"),
                        "description": .string("Max results (default 500)")
                    ])
                ]),
                "required": .array([.string("app_id")])
            ])
        )
    }

    func getPublishStateTool() -> Tool {
        Tool(
            name: "app_privacy_get_publish_state",
            description: "Get publish state for an app's privacy details (published Bool, lastPublished date, lastPublishedBy). Calls `GET /iris/v1/apps/{appId}/dataUsagePublishState` on the unofficial Iris API.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "app_id": .object([
                        "type": .string("string"),
                        "description": .string("App ID")
                    ])
                ]),
                "required": .array([.string("app_id")])
            ])
        )
    }

    func createUsageTool() -> Tool {
        Tool(
            name: "app_privacy_create_usage",
            description: "Create a new App Privacy data usage entry — one (category, purpose, protection) tuple for an app. For DATA_NOT_COLLECTED, omit category_id and purpose_id. Calls `POST /iris/v1/appDataUsages` on the unofficial Iris API.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "app_id": .object([
                        "type": .string("string"),
                        "description": .string("App ID")
                    ]),
                    "category_id": .object([
                        "type": .string("string"),
                        "description": .string("Data category enum (e.g. PAYMENT_INFORMATION). Omit for DATA_NOT_COLLECTED entries. Use app_privacy_list_categories.")
                    ]),
                    "purpose_id": .object([
                        "type": .string("string"),
                        "description": .string("Purpose enum (e.g. APP_FUNCTIONALITY). Omit for DATA_NOT_COLLECTED entries. Use app_privacy_list_purposes.")
                    ]),
                    "data_protection_id": .object([
                        "type": .string("string"),
                        "description": .string("Protection enum (DATA_LINKED_TO_YOU / DATA_NOT_LINKED_TO_YOU / DATA_USED_TO_TRACK_YOU / DATA_NOT_COLLECTED). Always required.")
                    ])
                ]),
                "required": .array([.string("app_id"), .string("data_protection_id")])
            ])
        )
    }

    func deleteUsageTool() -> Tool {
        Tool(
            name: "app_privacy_delete_usage",
            description: "Delete an App Privacy data usage entry by id. Calls `DELETE /iris/v1/appDataUsages/{id}` on the unofficial Iris API.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "usage_id": .object([
                        "type": .string("string"),
                        "description": .string("AppDataUsage entry ID (from app_privacy_list_usages)")
                    ])
                ]),
                "required": .array([.string("usage_id")])
            ])
        )
    }

    func publishTool() -> Tool {
        Tool(
            name: "app_privacy_publish",
            description: "Publish the current draft App Privacy details for an app (moves them from draft to live on the App Store). Resolves the publish state ID via `GET /iris/v1/apps/{appId}/dataUsagePublishState`, then PATCHes published=true.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "app_id": .object([
                        "type": .string("string"),
                        "description": .string("App ID")
                    ])
                ]),
                "required": .array([.string("app_id")])
            ])
        )
    }

    func unpublishTool() -> Tool {
        Tool(
            name: "app_privacy_unpublish",
            description: "Mark App Privacy details as unpublished (revert to draft state). PATCHes published=false on the publish state resource.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "app_id": .object([
                        "type": .string("string"),
                        "description": .string("App ID")
                    ])
                ]),
                "required": .array([.string("app_id")])
            ])
        )
    }
}
