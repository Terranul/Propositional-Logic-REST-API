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
    let value = "(((a^b)v(c^d))=((a^b)v(c^d)))"
    // small enough example to test exhaustively
    do {
        let base: any Statement = try parser.parseStatement(value: value)
         #expect(base.getStatement() == "~~a")
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
    let value = "(avbvc)"
    do {
        let base: any Statement = try parser.parseStatement(value: value)
         #expect(base.getStatement() == "((a v b) v c)")
    } catch {
        #expect(Bool(false))
    }
}

@Suite("linear parsing tests")
struct LinearParseTests {
    @Test func testParseCorrectSyntax() async throws {
        do {
            var stat = try linearParse(input: "(a^b)")
            #expect(stat.getStatement() == "(a ^ b)")
            stat = try linearParse(input: "((a^b)v(d^c))")
            #expect(stat.getStatement() == "((a ^ b) v (d ^ c))")
            stat = try linearParse(input: "~a")
            #expect(stat.getStatement() == "~a")
            stat = try linearParse(input: "(~avb)")
            #expect(stat.getStatement() == "(~a v b)")
            stat = try linearParse(input: "~(~avb)")
            #expect(stat.getStatement() == "~(~a v b)")
            stat = try linearParse(input: "~-+(~avb)")
            #expect(stat.getStatement() == "~-+(~a v b)")
            stat = try linearParse(input: "(av(c^d))")
            #expect(stat.getStatement() == "(a v (c ^ d))")
            stat = try linearParse(input: "((av(c^d))^z)")
            #expect(stat.getStatement() == "((a v (c ^ d)) ^ z)")
            stat = try linearParse(input: "((av(c|d))=z)")
            #expect(stat.getStatement() == "((a v (c | d)) = z)")
            stat = try linearParse(input: "(((a^b)v(c^d))=((a^b)v(c^d)))")
        } catch {
            #expect(Bool(false))
        }
    }

    @Test func testParseIncorrectSyntax() async throws {
        do {
            //var stat = try linearParse(input: "(aab^)")
            var stat = try linearParse(input: "(then)")
        } catch EvalError.MalformedStatement(let message) {
            print(message)
        }
    }
}


