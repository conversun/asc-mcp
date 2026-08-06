import Foundation
import MCP

extension AppPrivacyWorker {

    private static let offlineNote = """
    This tool answers from local reference data and makes no App Store Connect request. \
    Apple does not expose privacy details in the public App Store Connect API, so the \
    declaration itself must be applied in App Store Connect.
    """

    func listCategoriesTool() -> Tool {
        Tool(
            name: "app_privacy_list_categories",
            description: "List the 35 App Store privacy data types, each with the label group it appears under (Contact Info, Health & Fitness, Location, Identifiers, and so on). \(Self.offlineNote)",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([:]),
                "additionalProperties": .bool(false)
            ])
        )
    }

    func listPurposesTool() -> Tool {
        Tool(
            name: "app_privacy_list_purposes",
            description: "List the 6 App Store privacy data usage purposes (Third-Party Advertising, Developer's Advertising, Analytics, Product Personalization, App Functionality, Other Purposes) with what each one covers. \(Self.offlineNote)",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([:]),
                "additionalProperties": .bool(false)
            ])
        )
    }

    func listProtectionsTool() -> Tool {
        Tool(
            name: "app_privacy_list_protections",
            description: "List the 4 App Store privacy data protection levels (DATA_LINKED_TO_YOU, DATA_NOT_LINKED_TO_YOU, DATA_USED_TO_TRACK_YOU, DATA_NOT_COLLECTED) with what each one means. \(Self.offlineNote)",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([:]),
                "additionalProperties": .bool(false)
            ])
        )
    }
}
