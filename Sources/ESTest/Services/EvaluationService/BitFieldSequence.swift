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
        return BitFieldSequence(sequence: Set((value.getSequence().map { field in 
            var newValue = field
            for selfField in self.sequence {
                newValue = merge(newValue, with: selfField)
            }
            return newValue
        })))
    }

    func negate() {
        self.sequence = Set(self.sequence.map { bitfield in
            return bitfield.negate()
        })
    }

    static func getAlwaysFalseBitField() -> BitField {
        return BitField(from: 2147483647)
    }

    static func getAlwaysTrueBitField() -> BitField {
        return BitField(from: -1)
    }

    // in the future should probably incorporated into BitField, but for now, it is better placed here becuase the logic
    // doesn't align with the original bitfield idea
    func merge(_ valueA: BitField, with valueB: BitField) -> BitField {
        // we want to first check for the differences in the statement with an xor, 
        let xor = valueA.removeFlagBits() ^ valueB.removeFlagBits()
        // the differences must line of with one of the flags
        let Aintersection = valueA.extractFlagBits() & xor
        let Bintersection: Int32 = valueB.extractFlagBits() & xor
        if (Aintersection | Bintersection == xor) {
            // valid merge
            let zeroesB: Int32 = ~valueB.removeFlagBits() & Aintersection
            let newStatementBits: Int32 = valueA.removeFlagBits() | zeroesB
            // deal with the flag  bits now
            let newFlagBits: Int32 = ~zeroesB & valueA.extractFlagBits()
            return BitField(statementBits: newStatementBits, flagBits: newFlagBits)
        }
        return BitFieldSequence.getAlwaysFalseBitField()
    }

}