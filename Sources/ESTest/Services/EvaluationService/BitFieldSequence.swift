import OrderedCollections

class BitFieldSequence: Equatable  {


    // number of flag bits reserved for other purposes. Currently 2 flag bits are reserved to represent overall false and true outcomes
    static let RESERVED_BIT_COUNT: Int = 2

    // a bitfield has all flag bits being one, then you can say that the outcome will always be true.
    // we will then represent an always false bitfield with the same conditions as an always true bitfield but swapping
    // the last flag bit for a 0.
    // this is truly getting out of hand  

    var sequence: Set<BitField>

    init(sequence: Set<BitField>) {
        self.sequence = sequence
    }

    init(value: BitField) {
        self.sequence = [value]
    }

    func getSequence() -> Set<BitField> {
        return self.sequence 
    }

    static func == (lhs: BitFieldSequence, rhs: BitFieldSequence) -> Bool {
        for value in lhs.sequence {
            if (!(rhs.sequence.contains(value))) {
                return false
            }
        }
        return true
    }

    func union(with value: BitFieldSequence) -> BitFieldSequence {
        return BitFieldSequence(sequence: self.sequence.union(value.getSequence()))
    }

    func intersect(with value: BitFieldSequence) -> BitFieldSequence {
        guard value != self else {return value}
        // like factoring out terms (a + b)(c + d) = ac + ad + bc + bd
        var newSequence = Set<BitField>()
        for curValue in self.sequence {
            for newValue in value.getSequence() {
                newSequence.insert(BitFieldSequence.merge(curValue, with: newValue))
            }
        }
        return BitFieldSequence(sequence: newSequence)
    }

    // makes room for additional variables by shifting positions over
    // throws StatementError.InvalidOperation when you exceed the 15 variable max limit
    func addVariables(variableCount: Int) throws {
        // we don't know the total amount of variables since each statement may vary; we must check every time
        var newSequence = Set<BitField>()
        for curValue in self.sequence {
            if ((Int64(curValue.extractStatementBits()) << variableCount) >= Int64(1 << 16)) {
                throw StatementError.InvalidOperation("Too many variables present (max 15).")
            } else {
                newSequence.insert(BitField(from: curValue.value << variableCount))
            }
        }
    }

    // 
    // func getStatement() -> LazyEvalComplexStatement {

    // }


    // wrong currently
    func negate() -> BitFieldSequence {
        var andSequence: [BitFieldSequence] = [] // meant to be a list of sequences to be intersected
        for bitfield: BitField in self.sequence {
            andSequence.append(BitFieldSequence.intersectNegate(bitfield))
        }
        var curResult = andSequence.first!
        for value in andSequence {
            curResult = curResult.intersect(with: value)
        }
        return curResult
    }

    // 1|1 -> 00
    // not really used in our negation algo becuase it assumes that each bitfield in the sequence is fully reduced (represents a single variable only)
    static func unionNegate(_ value: Set<BitField>) -> BitFieldSequence {
        var newSequence = BitFieldSequence(value: punchHole(value.first!.negate()))
        for bitfield in value {
            let tempSequence = BitFieldSequence(value: punchHole(bitfield.negate()))
            newSequence = newSequence.intersect(with: tempSequence)
        }
        return newSequence
    }

    // 11 -> 0|0
    static func intersectNegate(_ value: BitField) -> BitFieldSequence {
        var newSequence: Set<BitField> = []
        // thanks to the way we've formatted the algorithm, the variables will all be the first n bits (we don't need to search for them)
        for i in value.getVariableIndices() {
            guard (i + BitFieldSequence.RESERVED_BIT_COUNT) < BitField.FLAG_BITS_BEGIN_INDEX else {continue}
            let cur: Int32 = (value.value >> i) & 1
            var newBitField: BitField = BitField(from: 1073741823)
            cur == 0 ? newBitField.delete(position: i) : newBitField.append(position: i)
            newBitField.deleteStar(position: i)
            let negatedBitField: BitField = punchHole(newBitField.negate())
            // I'll come back to make this look better I think
            newSequence.insert(negatedBitField)
        }
        return BitFieldSequence(sequence: newSequence)
    }

    static func getAlwaysFalseBitField() -> BitField {
        return BitField(from: 2147483647)
    }

    static func getAlwaysTrueBitField() -> BitField {
        return BitField(from: -1)
    }

    func evaluate(outcome: [Bool]) -> Bool {
        let bitFieldOutcome: BitField = BitField(from: outcome, inOrder: false)
        for value in sequence {
            if (BitFieldSequence.convertToEvalConditions(value).matches(with: bitFieldOutcome)) {
                return true
            }
        }
        return false
    }

    func isSolved() -> Bool{
        return self.sequence.count == 1 && self.sequence.first == BitFieldSequence.getAlwaysTrueBitField()
    }

    func copy() -> BitFieldSequence {
        return BitFieldSequence(sequence: self.sequence)
    }

    // an eval bitfield as the leading bits as significant, we must replicate in regular bitfield for the matches algo to work
    static func convertToEvalConditions(_ bitValue: BitField) -> BitField {
        return BitField(from: bitValue.value | -1073741824) // 11000000000000000000000000000000
    }

    // in the future should probably incorporated into BitField, but for now, it is better placed here becuase the logic
    // doesn't align with the original bitfield idea
    static func merge(_ valueA: BitField, with valueB: BitField) -> BitField {
        // we want to first check for the differences in the statement with an xor, 
        let xor = valueA.removeFlagBits() ^ valueB.removeFlagBits()
        // the differences must line of with one of the flags
        let Aintersection = valueA.extractFlagBits() & xor
        let Bintersection: Int32 = valueB.extractFlagBits() & xor
        if (Aintersection | Bintersection == xor) {
            // valid merge
            let zeroesB: Int32 = ~valueB.removeFlagBits() & Aintersection
            let newStatementBits: Int32 = valueA.removeFlagBits() & ~zeroesB
            // deal with the flag  bits now
            let newFlagBits: Int32 = valueB.extractFlagBits() & valueA.extractFlagBits()
            print("merged \(valueA.getStatementBits()) and \(valueB.getStatementBits()) to get the result \(BitField(statementBits: newStatementBits, flagBits: newFlagBits).getStatementBits())")
            return BitField(statementBits: newStatementBits, flagBits: newFlagBits)
        }
        return BitFieldSequence.getAlwaysFalseBitField()
    }

    func getDebugDescription() -> String {
        let stringSequence: String =  sequence.reduce("") { partial, cur in
            // we neeed the | (OR) partition between statements, so we'll put it after and remove it for the last one
            return partial + cur.getStatementBits() + "|"
        }
        return String(stringSequence.dropLast())
    }

    func map(_ operation: (BitField) -> BitField) {
        self.sequence = Set(self.sequence.map() { bitfield in
            return operation(bitfield)
        })
    }
}

 // resintates the reserved bits by adding 2 leading 0's to the sequence
    func punchHole(_ value: BitField) -> BitField {
        var temp =  BitField(from: value.value & Int32(1073741823))
        temp.append(position: BitField.FLAG_BITS_BEGIN_INDEX - 1) // some complication of the reserved bits that I forgot why it happens
        temp.append(position: BitField.FLAG_BITS_BEGIN_INDEX - 2)
        return temp
    }