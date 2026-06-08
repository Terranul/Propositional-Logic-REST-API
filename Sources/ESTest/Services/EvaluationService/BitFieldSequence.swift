class BitFieldSequence  {

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

    func union(with value: BitFieldSequence) {
        self.sequence = self.sequence.union(value.getSequence())
    }

    func intersect(with value: BitFieldSequence) {

    }

    // in the future should probably incorporated into BitField, but for now, it is better placed here becuase the logic
    // doesn't align with the original bitfield idea
    func merge(_ valueA: BitField, with valueB: BitField) -> BitField {
        // we want to first check for the differences in the statement with an xor, 
        let xor = valueA.extractStatementBits() ^ valueB.extractStatementBits()
    }
}