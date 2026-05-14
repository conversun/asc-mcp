import Testing
import Foundation
@testable import asc_mcp

@Suite("IAP Price Schedule Model Tests")
struct IAPPriceScheduleModelTests {

    /// Encodes a CreateIAPPriceScheduleRequest and verifies the JSON contains the
    /// `included` array Apple requires. Prior to v2.5.2 this array was missing
    /// entirely, which caused RELATIONSHIP.REQUIRED errors on the
    /// inAppPurchasePricePoint relationship.
    @Test func encodingProducesCompoundDocument() throws {
        let request = CreateIAPPriceScheduleRequest(
            data: .init(
                relationships: .init(
                    inAppPurchase: .init(data: ASCResourceIdentifier(type: "inAppPurchases", id: "iap-1")),
                    manualPrices: .init(data: [
                        ASCResourceIdentifier(type: "inAppPurchasePrices", id: "price-0")
                    ]),
                    baseTerritory: .init(data: ASCResourceIdentifier(type: "territories", id: "USA"))
                )
            ),
            included: [
                CreateIAPPriceInlineRequest(
                    id: "price-0",
                    attributes: .init(startDate: "2026-06-01", endDate: nil),
                    relationships: .init(
                        inAppPurchasePricePoint: .init(
                            data: ASCResourceIdentifier(type: "inAppPurchasePricePoints", id: "pp-100")
                        ),
                        inAppPurchaseV2: .init(
                            data: ASCResourceIdentifier(type: "inAppPurchases", id: "iap-1")
                        )
                    )
                )
            ]
        )

        let data = try JSONEncoder().encode(request)
        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        // Top-level: data + included must both exist
        #expect(json["data"] != nil)
        let included = try #require(json["included"] as? [[String: Any]])
        #expect(included.count == 1)

        // First included entry has the required relationships
        let entry = included[0]
        #expect(entry["type"] as? String == "inAppPurchasePrices")
        #expect(entry["id"] as? String == "price-0")

        let attrs = try #require(entry["attributes"] as? [String: Any])
        #expect(attrs["startDate"] as? String == "2026-06-01")

        let rels = try #require(entry["relationships"] as? [String: Any])

        let pp = try #require(rels["inAppPurchasePricePoint"] as? [String: Any])
        let ppData = try #require(pp["data"] as? [String: Any])
        #expect(ppData["type"] as? String == "inAppPurchasePricePoints")
        #expect(ppData["id"] as? String == "pp-100")

        let iapV2 = try #require(rels["inAppPurchaseV2"] as? [String: Any])
        let iapV2Data = try #require(iapV2["data"] as? [String: Any])
        #expect(iapV2Data["type"] as? String == "inAppPurchases")
        #expect(iapV2Data["id"] as? String == "iap-1")
    }

    /// manualPrices.data must reference the same placeholder ID as the included
    /// resource. If they drift, Apple rejects the request with an unresolved
    /// reference error.
    @Test func manualPricesReferencePlaceholderId() throws {
        let request = CreateIAPPriceScheduleRequest(
            data: .init(
                relationships: .init(
                    inAppPurchase: .init(data: ASCResourceIdentifier(type: "inAppPurchases", id: "iap-1")),
                    manualPrices: .init(data: [
                        ASCResourceIdentifier(type: "inAppPurchasePrices", id: "price-0"),
                        ASCResourceIdentifier(type: "inAppPurchasePrices", id: "price-1")
                    ]),
                    baseTerritory: .init(data: ASCResourceIdentifier(type: "territories", id: "USA"))
                )
            ),
            included: [
                CreateIAPPriceInlineRequest(
                    id: "price-0",
                    attributes: nil,
                    relationships: .init(
                        inAppPurchasePricePoint: .init(data: ASCResourceIdentifier(type: "inAppPurchasePricePoints", id: "pp-100")),
                        inAppPurchaseV2: .init(data: ASCResourceIdentifier(type: "inAppPurchases", id: "iap-1"))
                    )
                ),
                CreateIAPPriceInlineRequest(
                    id: "price-1",
                    attributes: nil,
                    relationships: .init(
                        inAppPurchasePricePoint: .init(data: ASCResourceIdentifier(type: "inAppPurchasePricePoints", id: "pp-200")),
                        inAppPurchaseV2: .init(data: ASCResourceIdentifier(type: "inAppPurchases", id: "iap-1"))
                    )
                )
            ]
        )

        let data = try JSONEncoder().encode(request)
        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        let topData = try #require(json["data"] as? [String: Any])
        let rels = try #require(topData["relationships"] as? [String: Any])
        let manual = try #require(rels["manualPrices"] as? [String: Any])
        let manualData = try #require(manual["data"] as? [[String: Any]])

        let manualIds = manualData.compactMap { $0["id"] as? String }
        let included = try #require(json["included"] as? [[String: Any]])
        let includedIds = included.compactMap { $0["id"] as? String }

        #expect(Set(manualIds) == Set(includedIds), "manualPrices.data references must match included entry IDs")
    }
}
