import Testing
@testable import ESTest

@Suite("equivalence tests")
struct EquivalenceTests {
    @Test func testIsEqual() async throws {
        do {
            #expect(try isEquivalent("(a^b)", with: "(a^(b^b))"))
            #expect((try isEquivalent("(a^b)", with: "(a^(bvb))")))
            #expect(!(try isEquivalent("(a^b)", with: "(a^(b^c))")))

            #expect(try isEquivalent("(a^b)", with: "(b^a)"))
            #expect(try isEquivalent("(a^(b^c))", with: "(a^(c^b))"))

            #expect(try isEquivalent("(a+b)", with: "(b+a)"))
            #expect(try isEquivalent("(a+(b+c))", with: "((b+c)+a)"))

            #expect(try isEquivalent("(a=b)", with: "(a=b)"))
            #expect(try isEquivalent("(a=(b=c))", with: "(a=(c=b))"))

            #expect(try isEquivalent("(a>b)", with: "(a>b)"))
            #expect(!(try isEquivalent("(a>(b>c))", with: "(a>(c>b))")))

            #expect(!(try isEquivalent("(a+b)", with: "(a^(b+b))")))
            #expect(!(try isEquivalent("(a=b)", with: "(a+b)")))
            #expect(!(try isEquivalent("(a>b)", with: "(a=b)")))
        } catch {
            #expect(Bool(false), "Unexpected error thrown: \(error)")
        }
    }

    @Test func testFindRelations() async throws {
    do {
        let andStatements = [
            "(a^b)",
            "(b^a)",
            "(a^(b^b))",
            "((b^a)^a)"
        ]

        let andRelations = try findEquivalenceRelations(for: andStatements)

        let xorStatements = [
            "(a+b)",
            "(b+a)",
            "(a+(b+b))",
            "((b+a)+a)"
        ]

        let xorRelations = try findEquivalenceRelations(for: xorStatements)

        let bicStatements = [
            "(a=b)",
            "(b=a)",
            "(a=((b=b)=b))"
        ]

        let bicRelations = try findEquivalenceRelations(for: bicStatements)

        #expect(andRelations == [
            "(a^b)": ["(b^a)", "(a^(b^b))", "((b^a)^a)"],
            "(b^a)": ["(a^b)", "(a^(b^b))", "((b^a)^a)"],
            "(a^(b^b))": ["(a^b)", "(b^a)", "((b^a)^a)"],
            "((b^a)^a)": ["(a^b)", "(b^a)", "(a^(b^b))"]
        ])

        #expect(xorRelations == [
            "(a+b)": ["(b+a)"],
            "(b+a)": ["(a+b)"],
            "(a+(b+b))": [],
            "((b+a)+a)": []
        ])

        #expect(bicRelations == [
            "(a=b)": ["(b=a)", "(a=((b=b)=b))"],
            "(b=a)": ["(a=b)", "(a=((b=b)=b))"],
            "(a=((b=b)=b))": ["(a=b)", "(b=a)"]
        ])

    } catch {
        #expect(Bool(false), "Unexpected error thrown: \(error)")
    }
}
}