import Foundation
import MCP

/// AppPrivacyWorker exposes the App Store privacy nutrition label vocabulary.
///
/// Apple manages privacy details outside the public App Store Connect REST API, so
/// this worker deliberately contains no App Store Connect operations. It answers
/// entirely from local reference data, which makes every tool offline, read-only,
/// and safe to call without credentials. Use it to plan or review a declaration;
/// apply the declaration in App Store Connect.
public final class AppPrivacyWorker: Sendable {
    public init() {}

    /// Get list of available tools
    public func getTools() async -> [Tool] {
        return [
            listCategoriesTool(),
            listPurposesTool(),
            listProtectionsTool()
        ]
    }

    /// Handle tool calls (for WorkerManager routing)
    public func handleTool(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        switch params.name {
        case "app_privacy_list_categories":
            return listCategories()
        case "app_privacy_list_purposes":
            return listPurposes()
        case "app_privacy_list_protections":
            return listProtections()
        default:
            throw MCPError.methodNotFound("Unknown tool: \(params.name)")
        }
    }
}
