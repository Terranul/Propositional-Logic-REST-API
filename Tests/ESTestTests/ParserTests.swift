import Testing
@testable import ESTest

// no before each :(

let a = 9

@Test func testLHS() async throws {
    let parser = StatementParser()
    let value = "((a^b)v(a^c))"
    let opIndex = value.index(value.startIndex, offsetBy: 6)
    let result = parser.parseLHS(value: value, opIndex: opIndex)
    #expect(result == "(a^b)")
}

@Test func testFindOperatorIndex() async throws {
    let parser = StatementParser()
    let value = "(av(a^c))"
    let result = try parser.getOperatorIndex(value: value)
    #expect(result == value.index(value.startIndex, offsetBy: 2))
}

@Test func testRHS() async throws {
    let parser = StatementParser()
    let value = "(av(a^c))"
    let opIndex = value.index(value.startIndex, offsetBy: 2)
    let result = parser.parseRHS(value: value, opIndex: opIndex)
    #expect(result == "(a^c)")
}

@Test func testRawStatement() async throws {
    let parser: StatementParser = StatementParser()
    do {
        let statement: any Statement = try parser.parseRawStatement(variable: "a", leadingOp: DefaultLeadingOperator())
        #expect(statement.getStatement() == "a")
    } catch {
        #expect(Bool(false))
    }
}

@Test func testStatement() async throws {
    let parser = StatementParser()
    let value = "~~a"
    // small enough example to test exhaustively
    do {
        let base: any Statement = try parser.parseStatement(value: value)
         #expect(base.getStatement() == "(a v a)")
    } catch {
        #expect(Bool(false))
    }
}

@Test func testValidateStatement() async throws {
    let result = validateStatement(for: "(a^bvc)")
    print("allowed")
    let result2 = validateStatement(for: "(a~^bvc)")
    let result3 = validateStatement(for: "a")
    let result4 = validateStatement(for: "(a^b)")
}

@Test func groupParserTests() async throws {
    let parser: groupedParser = groupedParser()
    let value = "(a^bv~c)"
    do {
        let base: any Statement = try parser.parseStatement(value: value)
         #expect(base.getStatement() == "((a v b) v c)")
    } catch {
        #expect(Bool(false))
    }
}


