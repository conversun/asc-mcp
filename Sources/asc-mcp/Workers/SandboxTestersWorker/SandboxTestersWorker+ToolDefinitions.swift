import Foundation
import MCP

// MARK: - Tool Definitions
extension SandboxTestersWorker {

    func listSandboxTestersTool() -> Tool {
        return Tool(
            name: "sandbox_list",
            description: "List sandbox testers for the current App Store Connect account",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "limit": .object([
                        "type": .string("integer"),
                        "description": .string("Max results (default: 25, max: 200)")
                    ]),
                    "next_url": .object([
                        "type": .string("string"),
                        "description": .string("Pagination URL from previous response to fetch next page")
                    ])
                ]),
                "required": .array([])
            ])
        )
    }

    func createSandboxTesterTool() -> Tool {
        return Tool(
            name: "sandbox_create",
            description: "Create a new sandbox Apple Account for testing IAP / subscriptions. Uses POST /v1/sandboxTesters which is NOT in Apple's public API reference but is exposed for JWT API keys (the same endpoint fastlane spaceship calls). Apple may reject calls with 4xx if the endpoint is restricted for your team \u{2014} fall back to the App Store Connect web UI in that case. Email MUST be brand new (not associated with any existing Apple ID). Password must satisfy Apple's iCloud complexity rules.",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "first_name": .object([
                        "type": .string("string"),
                        "description": .string("Tester first name")
                    ]),
                    "last_name": .object([
                        "type": .string("string"),
                        "description": .string("Tester last name")
                    ]),
                    "email": .object([
                        "type": .string("string"),
                        "description": .string("Brand-new email address. Must NOT be tied to any existing Apple ID. Subaddressing tip: use base+tag@domain for multiple regions.")
                    ]),
                    "password": .object([
                        "type": .string("string"),
                        "description": .string("Strong password (>=8 chars, mixed case + digit + special).")
                    ]),
                    "confirm_password": .object([
                        "type": .string("string"),
                        "description": .string("Must match password.")
                    ]),
                    "secret_question": .object([
                        "type": .string("string"),
                        "description": .string("Optional security question.")
                    ]),
                    "secret_answer": .object([
                        "type": .string("string"),
                        "description": .string("Optional security answer.")
                    ]),
                    "birth_date": .object([
                        "type": .string("string"),
                        "description": .string("Optional YYYY-MM-DD date of birth.")
                    ]),
                    "app_store_territory": .object([
                        "type": .string("string"),
                        "description": .string("Optional storefront territory code (USA, GBR, JPN, etc.).")
                    ])
                ]),
                "required": .array([
                    .string("first_name"),
                    .string("last_name"),
                    .string("email"),
                    .string("password"),
                    .string("confirm_password")
                ])
            ])
        )
    }

    func updateSandboxTesterTool() -> Tool {
        return Tool(
            name: "sandbox_update",
            description: "Update a sandbox tester's settings (territory, interrupt purchases, subscription renewal rate)",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "sandbox_tester_id": .object([
                        "type": .string("string"),
                        "description": .string("Sandbox tester ID")
                    ]),
                    "territory": .object([
                        "type": .string("string"),
                        "description": .string("Territory code (e.g. USA, GBR, JPN)")
                    ]),
                    "interrupt_purchases": .object([
                        "type": .string("boolean"),
                        "description": .string("Whether to interrupt purchases for testing interrupted purchase flows")
                    ]),
                    "subscription_renewal_rate": .object([
                        "type": .string("string"),
                        "description": .string("Subscription renewal rate for testing"),
                        "enum": .array([
                            .string("MONTHLY_RENEWAL_EVERY_ONE_HOUR"),
                            .string("MONTHLY_RENEWAL_EVERY_THIRTY_MINUTES"),
                            .string("MONTHLY_RENEWAL_EVERY_FIFTEEN_MINUTES"),
                            .string("MONTHLY_RENEWAL_EVERY_FIVE_MINUTES"),
                            .string("MONTHLY_RENEWAL_EVERY_THREE_MINUTES")
                        ])
                    ])
                ]),
                "required": .array([.string("sandbox_tester_id")])
            ])
        )
    }

    func clearPurchaseHistoryTool() -> Tool {
        return Tool(
            name: "sandbox_clear_purchase_history",
            description: "Clear purchase history for one or more sandbox testers (bulk operation supported)",
            inputSchema: .object([
                "type": .string("object"),
                "properties": .object([
                    "sandbox_tester_ids": .object([
                        "type": .string("array"),
                        "description": .string("Array of sandbox tester IDs to clear purchase history for"),
                        "items": .object([
                            "type": .string("string")
                        ])
                    ])
                ]),
                "required": .array([.string("sandbox_tester_ids")])
            ])
        )
    }
}
