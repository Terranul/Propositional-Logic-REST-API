@testable import ESTest
import VaporTesting
import Testing

struct EvalApiTests {

    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test func testSingleInputs() async throws {
        try await withApp() { app in
            try await app.testing().test(.POST, "eval/(a^b)", beforeRequest: { req in
                let dict: [String: Bool] = ["a": true, "b": true]
                try req.content.encode(dict)
            },
            afterResponse: { res in
                let result = try res.content.decode(EvalTotalDTO.self)
                #expect(result.statement == "(a^b)")
            })
        }
    }
}