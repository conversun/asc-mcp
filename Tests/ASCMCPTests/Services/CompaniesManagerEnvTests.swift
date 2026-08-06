import Testing
@testable import asc_mcp

@Suite("CompaniesManager Environment Loading Tests")
struct CompaniesManagerEnvTests {
    @Test("Single team key loads with an issuer ID")
    func singleTeamKey() {
        let config = CompaniesManager.loadFromEnvironment(env: [
            "ASC_KEY_ID": "TESTKEY",
            "ASC_ISSUER_ID": "TESTISSUER",
            "ASC_PRIVATE_KEY_PATH": "/tmp/key.p8"
        ])

        #expect(config?.companies.count == 1)
        #expect(config?.companies.first?.issuerID == "TESTISSUER")
        #expect(config?.companies.first?.isIndividualKey == false)
    }

    @Test("Single individual key loads without an issuer ID")
    func singleIndividualKey() {
        let config = CompaniesManager.loadFromEnvironment(env: [
            "ASC_KEY_ID": "TESTKEY",
            "ASC_PRIVATE_KEY_PATH": "/tmp/key.p8"
        ])

        #expect(config?.companies.count == 1)
        #expect(config?.companies.first?.issuerID == nil)
        #expect(config?.companies.first?.isIndividualKey == true)
    }

    @Test("Individual key loads from inline key content")
    func individualKeyWithInlineContent() {
        let config = CompaniesManager.loadFromEnvironment(env: [
            "ASC_KEY_ID": "TESTKEY",
            "ASC_PRIVATE_KEY": "-----BEGIN PRIVATE KEY-----\nTEST\n-----END PRIVATE KEY-----"
        ])

        #expect(config?.companies.first?.isIndividualKey == true)
        #expect(config?.companies.first?.privateKeyContent != nil)
        #expect(config?.companies.first?.privateKeyPath == "")
    }

    @Test("Multi-company env loads team and individual keys side by side")
    func multiCompanyMixedKeyTypes() {
        let config = CompaniesManager.loadFromEnvironment(env: [
            "ASC_COMPANY_1_KEY_ID": "TEAMKEY",
            "ASC_COMPANY_1_ISSUER_ID": "TEAMISSUER",
            "ASC_COMPANY_1_KEY_PATH": "/tmp/team.p8",
            "ASC_COMPANY_2_KEY_ID": "INDIVKEY",
            "ASC_COMPANY_2_KEY_PATH": "/tmp/individual.p8"
        ])

        #expect(config?.companies.count == 2)
        #expect(config?.companies.first?.isIndividualKey == false)
        #expect(config?.companies.last?.isIndividualKey == true)
    }

    @Test("Multi-company scanning stops at the first missing key ID")
    func multiCompanyScanStopsAtGap() {
        let config = CompaniesManager.loadFromEnvironment(env: [
            "ASC_COMPANY_1_KEY_ID": "FIRST",
            "ASC_COMPANY_1_KEY_PATH": "/tmp/first.p8",
            "ASC_COMPANY_3_KEY_ID": "THIRD",
            "ASC_COMPANY_3_KEY_PATH": "/tmp/third.p8"
        ])

        #expect(config?.companies.count == 1)
        #expect(config?.companies.first?.keyID == "FIRST")
    }

    @Test("Missing key ID returns nil")
    func missingKeyIDReturnsNil() {
        #expect(CompaniesManager.loadFromEnvironment(env: [:]) == nil)
    }

    @Test("Key ID without any private key material returns nil")
    func missingKeyMaterialReturnsNil() {
        #expect(CompaniesManager.loadFromEnvironment(env: ["ASC_KEY_ID": "TESTKEY"]) == nil)
    }
}
