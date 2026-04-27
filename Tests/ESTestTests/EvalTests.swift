import Testing
@testable import ESTest

@Test func testEvalComplexStatement() async throws {
    let parser = StatementParser()
    let value = "((a^b)v(a^c))"
    // small enough example to test exhaustively
    do {
        let base = try parser.parseStatement(value: value)
         #expect(base.getStatement() == "((a ^ b) v (a ^ c))")
         #expect(base.evaluate(resolutionMap: ["a": true, "b": false, "c": true]))
         #expect(!base.evaluate(resolutionMap: ["a": true, "b": false, "c": false]))
         
    } catch {
        #expect(Bool(false))
    }
}

@Test func testEvalRawStatement() async throws {
    let parser = StatementParser()
    let value = "(a^b)"
    let opIndex = value.index(value.startIndex, offsetBy: 2)
    do {
        let statement: any Statement = try parser.parseRawStatement(value: value, opIndex: opIndex)
        #expect(statement.getStatement() == "(a ^ b)")
        #expect(!statement.evaluate(resolutionMap: ["a": true, "b": false]))
        #expect(statement.evaluate(resolutionMap: ["a": true, "b": true]))
    } catch {
        #expect(Bool(false))
    }
}