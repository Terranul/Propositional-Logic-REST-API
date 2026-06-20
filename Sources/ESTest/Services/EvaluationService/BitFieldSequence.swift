import OrderedCollections

class BitFieldSequence  {

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

    func union(with value: BitFieldSequence) -> BitFieldSequence {
        return BitFieldSequence(sequence: self.sequence.union(value.getSequence()))
    }

    func intersect(with value: BitFieldSequence) -> BitFieldSequence {
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

    func negate() -> BitFieldSequence{
        return BitFieldSequence(sequence: Set(self.sequence.map { bitfield in
            return bitfield.negate()
        }))
    }

    static func getAlwaysFalseBitField() -> BitField {
        return BitField(from: 2147483647)
    }

    static func getAlwaysTrueBitField() -> BitField {
        return BitField(from: -1)
    }

    func evaluate(outcome: [Bool]) -> Bool {
        let bitFieldOutcome: BitField = BitField(from: outcome)
        for value in sequence {
            if (BitFieldSequence.convertToEvalConditions(value).matches(with: bitFieldOutcome)) {
                return true
            }
        }
        return false
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