import Testing
@testable import ESTest

@Test func testEvalComplexStatement() async throws {
    let parser = StatementParser()
    let value = "(/(a^b)v(a^c))"
    // small enough example to test exhaustively
    do {
        let base = try parser.parseStatement(value: value)
         #expect(base.getStatement() == "(~(a ^ b) v (a ^ c))")
         #expect(try base.evaluate(resolutionMap: ["a": true, "b": false, "c": false]))
         #expect(try !base.evaluate(resolutionMap: ["a": true, "b": true, "c": false]))
         
    } catch {
        #expect(Bool(false))
    }
}

@Test func testEvalInvalidEmptyOrStatement() async throws {
    let parser = StatementParser()
    let value = "(v)"
    
    do {
        _ = try parser.parseStatement(value: value)
        #expect(Bool(false))
    } catch {
        #expect(Bool(true))
    }
}

@Test func testEvalRawStatement() async throws {
    let parser = StatementParser()
    let value = "a"
    do {
        let statement: any Statement = try parser.parseRawStatement(variable: value, leadingOp: TrueSlashOperator())
        #expect(statement.getStatement() == "/a")
        #expect(try statement.evaluate(resolutionMap: ["a": true, "b": false]))
        #expect(try statement.evaluate(resolutionMap: ["a": true, "b": true]))
    } catch {
        #expect(Bool(false))
    }
}

@Test func initCompStatementWithComponents() async throws {
    let components = [RawStatement(variable: "a", leadingOp: NotOperator()), RawStatement(variable: "b", leadingOp: NotOperator()), RawStatement(variable: "c", leadingOp: DefaultLeadingOperator())]
    let complexStatement = ComplexStatement(components: components, op: OrOperator())
    #expect(complexStatement.getStatement() == "(~a v (~b v c))")
}