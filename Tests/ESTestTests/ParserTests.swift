import Testing
@testable import ESTest

// no before each :(

@Test func testLHS() async throws {
    let parser = StatementParser()
    let value = "((a^b)v(a^c))"
    let opIndex = value.index(value.startIndex, offsetBy: 6)
    let result = parser.parseLHS(value: value, opIndex: opIndex)
    #expect(result == "(a^b)")
}

@Test func testFindOperatorIndex() async throws {
    let parser = StatementParser()
    let value = "((a^b)v(a^c))"
    let result = parser.getOperatorIndex(value: value)
    #expect(result == value.index(value.startIndex, offsetBy: 6))
}

@Test func testRHS() async throws {
    let parser = StatementParser()
    let value = "((a^b)v(a^c))"
    let opIndex = value.index(value.startIndex, offsetBy: 6)
    let result = parser.parseRHS(value: value, opIndex: opIndex)
    #expect(result == "(a^c)")
}

@Test func testRawStatement() async throws {
    let parser = StatementParser()
    let value = "(a^b)"
    let opIndex = value.index(value.startIndex, offsetBy: 2)
    do {
        let statement: any Statement = try parser.parseRawStatement(value: value, opIndex: opIndex)
        #expect(statement.getStatement() == "(a ^ b)")
    } catch {
        #expect(Bool(false))
    }
}

@Test func testStatement() async throws {
    let parser = StatementParser()
    let value = "((a^b)v(a^c))"
    // small enough example to test exhaustively
    do {
        let base = try parser.parseStatement(value: value)
         #expect(base.getStatement() == "((a ^ b) v (a ^ c))")
    } catch {
        #expect(Bool(false))
    }
}


