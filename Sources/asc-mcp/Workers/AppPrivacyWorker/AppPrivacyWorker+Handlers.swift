import Foundation
import MCP

// MARK: - Tool Handlers
extension AppPrivacyWorker {

    private static let applyGuidance = "Apply the declaration in App Store Connect under App Privacy; the public App Store Connect API does not expose these resources."

    /// Lists every App Store privacy data type with its label group.
    /// - Returns: JSON with `categories` (id plus group), `groups`, and `count`.
    func listCategories() -> CallTool.Result {
        let categories = AppPrivacyReferenceData.categories
        var groups: [String] = []
        for category in categories where !groups.contains(category.group) {
            groups.append(category.group)
        }

        return MCPResult.json(
            .object([
                "success": .bool(true),
                "categories": .array(categories.map {
                    .object([
                        "id": .string($0.id),
                        "group": .string($0.group)
                    ])
                }),
                "groups": .array(groups.map { .string($0) }),
                "count": .int(categories.count),
                "source": .string("local_reference_data"),
                "note": .string(Self.applyGuidance)
            ]),
            text: "\(categories.count) App Store privacy data types across \(groups.count) label groups"
        )
    }

    /// Lists every App Store privacy data usage purpose.
    /// - Returns: JSON with `purposes` (id plus summary) and `count`.
    func listPurposes() -> CallTool.Result {
        let purposes = AppPrivacyReferenceData.purposes

        return MCPResult.json(
            .object([
                "success": .bool(true),
                "purposes": .array(purposes.map {
                    .object([
                        "id": .string($0.id),
                        "summary": .string($0.summary)
                    ])
                }),
                "count": .int(purposes.count),
                "source": .string("local_reference_data"),
                "note": .string(Self.applyGuidance)
            ]),
            text: "\(purposes.count) App Store privacy data usage purposes"
        )
    }

    /// Lists every App Store privacy data protection level.
    /// - Returns: JSON with `protections` (id plus summary) and `count`.
    func listProtections() -> CallTool.Result {
        let protections = AppPrivacyReferenceData.protections

        return MCPResult.json(
            .object([
                "success": .bool(true),
                "protections": .array(protections.map {
                    .object([
                        "id": .string($0.id),
                        "summary": .string($0.summary)
                    ])
                }),
                "count": .int(protections.count),
                "source": .string("local_reference_data"),
                "note": .string(Self.applyGuidance)
            ]),
            text: "\(protections.count) App Store privacy data protection levels"
        )
    }
}
