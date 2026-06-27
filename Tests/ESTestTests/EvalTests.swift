import Testing
import OrderedCollections
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

// tests for the new evaluation below

@Test func generalEvalTesting() async throws {
    let parser = StatementParser()
    let value = "((avc)^~(b^a))"
    do {
        let base = try parser.parseStatement(value: value)
        let outcome = try base.evaluateOutcomeMatch(resolutionMap: ["a": true, "b": true, "c": false])
         #expect(try base.evaluateOutcomeMatch(resolutionMap: ["a": false, "b": false, "c": true]))
         #expect(try !base.evaluateOutcomeMatch(resolutionMap: ["a": true, "b": true, "c": true]))
    } catch {
        #expect(Bool(false))
    }
}

@Test func initCompStatementWithComponents() async throws {
    let components = [RawStatement(variable: "a", leadingOp: NotOperator()), RawStatement(variable: "b", leadingOp: NotOperator()), RawStatement(variable: "c", leadingOp: DefaultLeadingOperator())]
    let complexStatement = ComplexStatement(components: components, op: OrOperator())
    #expect(complexStatement.getStatement() == "(~a v (~b v c))")
}

// testing BitFieldSequence below here

@Suite("BitFieldSequence Tests")
struct BSTests {



    @Test func testUnion() async throws {
        let a = BitField(from: [true, false, true], inOrder: true)
        let b = BitField(from: [true, false, false], inOrder: true)
        let c = BitField(from: [true, true, false], inOrder: true)
        let sequence = BitFieldSequence(value: a)
        let abUnion = sequence.union(with: BitFieldSequence(value: b))
        #expect(abUnion.getDebugDescription() == "00000000000000000000000000000101|00000000000000000000000000000100")
        let abcUnion = abUnion.union(with: BitFieldSequence(value: c))
        #expect(abcUnion.getDebugDescription() == "00000000000000000000000000000101|00000000000000000000000000000100|00000000000000000000000000000110")
    }

    @Test func testMerge() async throws {
        // variable naming convention: s = "star", z = "zero", o = "one"
        let ssz = createBitField(value: "00000000000001100000000000000110")
        let szz = createBitField(value: "00000000000001000000000000000100")
        var result = BitFieldSequence.merge(ssz, with: szz)
        #expect(result.getStatementBits() == "00000000000001000000000000000100")
        let oss = createBitField(value: "00000000000000110000000000000111")
        let oos = createBitField(value: "00000000000000010000000000000111")
        let zos = createBitField(value: "00000000000000010000000000000011")
        result = BitFieldSequence.merge(oss, with: oos)
        #expect(result.getStatementBits() == "00000000000000010000000000000111")
        let soo = createBitField(value: "00000000000001000000000000000111")
        result = BitFieldSequence.merge(soo, with: zos)
        #expect(result.getStatementBits() == "00000000000000000000000000000011")
    }

   @Test func testIntersect() async throws {
        let a = BitField(from: [true, false, true], inOrder: true)
        let b = BitField(from: [true, false, false], inOrder: true)
        let c = createBitField(value: "00000000000000110000000000000111") // 1**
        let sequence = BitFieldSequence(value: a)
        let abUnion = sequence.union(with: BitFieldSequence(value: b))
        let abUnionIntersectC = abUnion.intersect(with: BitFieldSequence(value: c))
        #expect(abUnionIntersectC.getDebugDescription() == "00000000000000000000000000000101|00000000000000000000000000000100")
   }

   @Test func testArrangeVariables() async throws {
        let a = RawStatement(variable: "a", leadingOp: DefaultLeadingOperator())
        let b = RawStatement(variable: "b", leadingOp: DefaultLeadingOperator())
        ComplexStatement.arrangeVariables(lhs: a, rhs: b)
        #expect(a.getBitFieldSequence().getDebugDescription() == "00000000000000000000000000000010")
        #expect(b.getBitFieldSequence().getDebugDescription() == "00000000000000000000000000000001")
   }   

   @Test func testRearangeVariables() async throws {
        let bit = createBitField(value: "00000000000000000000000000000011")
        let studyVariables: OrderedSet<Variable> = OrderedSet(["a", "b"])
        let masterSet: OrderedSet<Variable> = OrderedSet(["a", "c", "b", "d"])
        let result = ComplexStatement.rearrangeStudyBitField(bitfield: bit, studyVariables: studyVariables, masterSequence: masterSet)
        #expect(result.getStatementBits() == "00000000000000000000000000000101")
   } 

   @Test func testCreateBitFieldSequence() async throws {
        
   }

   @Test func testIntersectNegate() async throws {
        var subject: BitField = createBitField(value: "00111111111110001111111111111111")
        var result = BitFieldSequence.intersectNegate(subject)
        #expect(result.getDebugDescription() == "00111111111111101111111111111110|00111111111111011111111111111101|00111111111110111111111111111011")
        subject = createBitField(value: "00111111111110101111111111111110")
        result = BitFieldSequence.intersectNegate(subject)
        #expect(result.getDebugDescription() == "00111111111111001111111111111111")
   }

   @Test func testUnionNegate() async throws {
        let subject1 =  createBitField(value: "00111111111111101111111111111110")
        let subject2 = createBitField(value: "00111111111111011111111111111101")
        let result = BitFieldSequence.unionNegate([subject1, subject2])
        #expect(result.getDebugDescription() == "00111111111111001111111111111111")
   }       

   @Test func testNegate() async throws {
        let subject1 = createBitField(value: "00111111111110101111111111111110")
        let subject2 = createBitField(value: "00111111111111001111111111111100")
        let sequence = BitFieldSequence(sequence: [subject1, subject2])
        let result: BitFieldSequence = sequence.negate()
        #expect(result.getDebugDescription() == "00111111111111001111111111111111")
   } 
}