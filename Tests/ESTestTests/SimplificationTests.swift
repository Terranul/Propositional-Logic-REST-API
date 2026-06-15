import Testing
import Collections
@testable import ESTest

func createBitField(value: String) -> BitField {
    assert(value.count == 32)
    var shiftCount = 31
    var result: Int32 = 0
    for bit in value {
        if (bit == "1") {
            result += 1 << shiftCount
        }
        shiftCount -= 1
    }
    return BitField(from: result)
}

@Suite("simplifications Tests")
struct SimpTests {
    @Test func testDebugDescription() async throws {
        let val = BitField(from: 9)
        #expect(val.getStatementBits() == "00000000000000000000000000001001")
    }

    @Test func testCreateBitField() async throws {
        let bitField = createBitField(value: "00000000000000000000000000001001")
         #expect(bitField.getStatementBits() == "00000000000000000000000000001001")
    }

    @Test func testConvert() async throws {
        let t: BitField = BitField(from: [true, false, true])
        #expect(t.getStatementBits() == "00000000000000000000000000000101")  
        let b: BitField = BitField(from: [false, false, true])
        #expect(b.getStatementBits() == "00000000000000000000000000000001")   
        let c: BitField = BitField(from: [true, false, false, true, true, false])
        #expect(c.getStatementBits() == "00000000000000000000000000100110")        
    }

    @Test func testPerformMerge() async throws {
        let t: BitField = BitField(from: [true, false, true])
        let s: BitField = BitField(from: [false, false, true])
        let result: BitField = t.perfromMerge(a: t, b: s, on: 2)
        #expect(result.getStatementBits() == "00000000000010000000000000000101")     
    }

    @Test func testMerge() async throws {
        let t: BitField = BitField(from: [true, false, true, false])
        let s: BitField = BitField(from: [false, false, true, false])
        do {
            let mergedT = try t.merge(b: s)
            #expect(mergedT.getStatementBits() == "00000000000010000000000000001010") 
        } catch {
            assertionFailure()
        }
        let b: BitField = BitField(from: [false, false, false, false])
        do {
            let mergedB = try b.merge(b: t)
            assertionFailure()
        } catch {
        }
        let a = createBitField(value: "00000000000001000000000000000011")
        let c = createBitField(value: "00000000000000100000000000000111")
        do {
            let mergedA = try a.merge(b: c)
            #expect(Bool(false))
        } catch {
        }
    }

    @Test func testMatches() async throws {
        let starBit = createBitField(value: "00000000000100000000000000001010")
         let t: BitField = BitField(from: [true, false, true, false])
         let s: BitField = BitField(from: [false, false, true, false])
         #expect(starBit.matches(with: s))
         #expect(starBit.matches(with: t))
    }

    @Test func testGetPrimeImplicants() async throws {
        // models (a ^ b) v c
        let primeImps: Set<BitField> = getRawBitfields([
            [false, false, true],
            [false, true,  true],
            [true,  false, true],
            [true,  true,  false],
            [true,  true,  true]
        ])
        let primeImplicants: Set<BitField> = try getPrimeImplicants(minterms: primeImps)
    }
    @Test func testGetEssentialImplicants() async throws {
        let rawImps = getRawBitfields([
            [false, false, true],
            [false, true,  true],
            [true,  false, true],
            [true,  true,  false],
            [true,  true,  true]
        ])
        var primeImps: Set<BitField> = []
        primeImps.insert(createBitField(value: "00000000000000010000000000000111"))
        primeImps.insert(createBitField(value: "00000000000001100000000000000111"))
        let essentialImplicants: Set<BitField> = getEssentialImplicants(primeImplicants: primeImps, outcomes: rawImps)
        let statement = convertToCNF(outcomes: essentialImplicants, variables: ["a", "b", "c"])
        print(statement.getStatement())
    }

    @Test func testSimplify() async throws {
        var result: any Statement = try StatementParser().parseStatement(value: "(a^a)")
        var simplified = try simplify(result)
        #expect(simplified.getStatement() == "a")
        result = try StatementParser().parseStatement(value: "(a^(avb))")
        simplified = try simplify(result)
        #expect(simplified.getStatement() == "a")
        result = try StatementParser().parseStatement(value: "(((avb)^(av~b))^(bvc))")
        simplified = try simplify(result)
        #expect(simplified.getStatement() == "(a ^ (b v c))")
        // result = try StatementParser().parseStatement(value: "((a>b)^(~a>c))")
        // simplified = try simplify(result)
        // #expect(simplified.getStatement() == "(a ^ (b v c))")
        result = try StatementParser().parseStatement(value: "((~c>d)|c)")
        simplified = try simplify(result)
        #expect(simplified.getStatement() == "(a ^ (b v c))")
    }

    // testing on local simplify
    @Test func testLocalSimplify() async throws {
        var result = try StatementParser().parseStatement(value: "(a^(bva))")
        var simplfiied = localSimplify(on: result)
        #expect(localSimplify(on: result).getStatement() == "a")
        result = try StatementParser().parseStatement(value: "((a^b)v(c^a))")
        simplfiied = localSimplify(on: result)
        #expect(localSimplify(on: result).getStatement() == "(a ^ (b v c))")  
    }

    @Test func testBitFieldMove() async throws {
        var input = createBitField(value: "00000000000000100000000000000011")
        input.move(from: 0, to: 2)
        #expect(input.getStatementBits() == "00000000000000100000000000000110")
        input.move(from: 1, to: 3)
        #expect(input.getStatementBits() == "00000000000010000000000000001100")
    }
}

