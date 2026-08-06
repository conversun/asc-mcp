import Foundation
import MCP
import Testing
@testable import asc_mcp

@Suite("App Privacy Worker Tests")
struct AppPrivacyWorkerTests {

    private func structuredObject(_ result: CallTool.Result) throws -> [String: Value] {
        #expect(result.isError == nil)
        let structured = try #require(result.structuredContent)
        guard case .object(let object) = structured else {
            Issue.record("Expected an object result")
            return [:]
        }
        return object
    }

    private func objects(_ value: Value?) throws -> [[String: Value]] {
        guard case .array(let array)? = value else {
            Issue.record("Expected an array result")
            return []
        }
        return array.compactMap {
            guard case .object(let object) = $0 else { return nil }
            return object
        }
    }

    @Test("app_privacy_list_categories returns every data type with its label group")
    func listCategoriesReturnsGroupedDataTypes() async throws {
        let worker = AppPrivacyWorker()
        let result = try await worker.handleTool(
            CallTool.Parameters(name: "app_privacy_list_categories", arguments: nil)
        )
        let object = try structuredObject(result)

        #expect(object["success"] == .bool(true))
        #expect(object["source"] == .string("local_reference_data"))
        #expect(object["count"] == .int(AppPrivacyReferenceData.categories.count))

        let categories = try objects(object["categories"])
        #expect(categories.count == AppPrivacyReferenceData.categories.count)
        for category in categories {
            #expect(category["id"] != nil)
            #expect(category["group"] != nil)
        }

        let ids = categories.compactMap { category -> String? in
            guard case .string(let id)? = category["id"] else { return nil }
            return id
        }
        #expect(Set(ids).count == ids.count, "Category IDs must be unique")
        #expect(ids.contains("PAYMENT_INFORMATION"))
        #expect(ids.contains("PRECISE_LOCATION"))
        #expect(ids.contains("CRASH_DATA"))

        let groups = try #require({ () -> [Value]? in
            guard case .array(let array)? = object["groups"] else { return nil }
            return array
        }())
        #expect(groups.contains(.string("Contact Info")))
        #expect(groups.contains(.string("Diagnostics")))
    }

    @Test("app_privacy_list_purposes returns the six declared purposes")
    func listPurposesReturnsAllPurposes() async throws {
        let worker = AppPrivacyWorker()
        let result = try await worker.handleTool(
            CallTool.Parameters(name: "app_privacy_list_purposes", arguments: nil)
        )
        let object = try structuredObject(result)

        #expect(object["count"] == .int(6))
        let purposes = try objects(object["purposes"])
        #expect(purposes.count == 6)

        let ids = purposes.compactMap { purpose -> String? in
            guard case .string(let id)? = purpose["id"] else { return nil }
            return id
        }
        #expect(Set(ids) == [
            "THIRD_PARTY_ADVERTISING",
            "DEVELOPERS_ADVERTISING",
            "ANALYTICS",
            "PRODUCT_PERSONALIZATION",
            "APP_FUNCTIONALITY",
            "OTHER_PURPOSES"
        ])
        for purpose in purposes {
            guard case .string(let summary)? = purpose["summary"] else {
                Issue.record("Every purpose needs a summary")
                continue
            }
            #expect(!summary.isEmpty)
        }
    }

    @Test("app_privacy_list_protections returns the four protection levels")
    func listProtectionsReturnsAllLevels() async throws {
        let worker = AppPrivacyWorker()
        let result = try await worker.handleTool(
            CallTool.Parameters(name: "app_privacy_list_protections", arguments: nil)
        )
        let object = try structuredObject(result)

        #expect(object["count"] == .int(4))
        let protections = try objects(object["protections"])
        let ids = protections.compactMap { protection -> String? in
            guard case .string(let id)? = protection["id"] else { return nil }
            return id
        }
        #expect(Set(ids) == [
            "DATA_LINKED_TO_YOU",
            "DATA_NOT_LINKED_TO_YOU",
            "DATA_USED_TO_TRACK_YOU",
            "DATA_NOT_COLLECTED"
        ])
    }

    @Test("app_privacy tools take no arguments and ignore stray input")
    func toolsDeclareNoInputsAndTolerateNone() async throws {
        let worker = AppPrivacyWorker()
        for tool in await worker.getTools() {
            guard case .object(let schema) = tool.inputSchema,
                  case .object(let properties)? = schema["properties"] else {
                Issue.record("\(tool.name) must declare an empty object schema")
                continue
            }
            #expect(properties.isEmpty)
            #expect(schema["required"] == nil)
        }
    }

    @Test("app_privacy tools are annotated read-only and closed-world")
    func toolsAreReadOnlyAndClosedWorld() async throws {
        let worker = AppPrivacyWorker()
        for tool in await worker.getTools().map(ToolMetadataPolicy.apply) {
            #expect(tool.annotations.readOnlyHint == true, "\(tool.name) must be read-only")
            #expect(tool.annotations.destructiveHint == false, "\(tool.name) must not be destructive")
            #expect(tool.annotations.openWorldHint == false, "\(tool.name) makes no network request")
        }
    }
}
