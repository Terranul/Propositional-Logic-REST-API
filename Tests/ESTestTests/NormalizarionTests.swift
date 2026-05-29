import Testing
@testable import ESTest

@Suite("Normalization Tests")
struct NormalizationTests {
    @Test func testLNF() async throws {
        let statement1: any Statement = try StatementParser().parseStatement(value: "~(a^b)")
        #expect(statement1.toLRF().getStatement() == "(~a v ~b)")
        let statement2: any Statement = try StatementParser().parseStatement(value: "~(~(avc)^b)")
        #expect(statement2.toLRF().getStatement() == "((a v c) v ~b)")
        let statement3: any Statement = try StatementParser().parseStatement(value: "~(~(avc)^b)")
        #expect(statement3.toLRF().getStatement() == "((a v c) v ~b)")
        let statement4: any Statement = try StatementParser().parseStatement(value: "~(~(a>c)^b)")
        //let result = statement4.toLRF()
        #expect(statement4.toLRF().getStatement() == "((~a v c) v ~b)")
        let statement5: any Statement = try StatementParser().parseStatement(value: "~-(~(a>c)^b)")
        #expect(statement5.toLRF().getStatement() == "+(~avc)")

    }
}