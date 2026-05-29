// application of Quine–McCluskey algorithm for simplifcation of prop logic statements

enum SimpErrors: Error {
    case InvalidBitMerge
}

class BitField {

    /*

        Represents the T/F sequence of a given inputs to a statements
        The bits starting from the left side (one's bit) to the size of the T/F inputs it the sequence
        The bits from the last bit to the bit before the size of the T/F sequence are flag bits to represent which bits don't
        need to assume either 1 or 0. 
    */

    var value: Int32

    init(from value: [Bool]) {
        self.value = 0
        self.value = self.convert(from: value)
    }

    init(from value: Int32) {
        self.value = value
    }

    func append(position: Int) {
        value += 1 << position
    }

    // converts sequence of bool to their binary representation: TFTF -> 1010
    private func convert(from value: [Bool]) -> Int32 {
        var target: Int32 = 0
        for i in 0..<value.count {
            if(value[i]) {
                target += 1 << i
            }
        }
        return target
    }

    // will only merge if there is exactly one different bit in the statement sequence
    // size is the number of variables (or the size of the statement sequence)
    func merge(a: BitField, b: BitField, size: Int) throws -> BitField {
        // when we xor, we want only one single bit remaining
        let onlyStatementSequenceA: Int32 = a.value << size
        let onlyStatementSequenceB: Int32 = b.value << size
        let diffBits: Int32 = onlyStatementSequenceA ^ onlyStatementSequenceB
        // BitFields were the statement sequence is all 0's should have been filtered out preliminarily but we will still account for it
        if (diffBits == 0) {
            throw SimpErrors.InvalidBitMerge
        } else {
            if (diffBits & (diffBits - 1) == 0) {
                // bingo 
                return perfromMerge(a: a, b: b, on: diffBits.trailingZeroBitCount)
            } else {
                throw SimpErrors.InvalidBitMerge
            }
        }
    }

    // index is 0 based
    private func perfromMerge(a: BitField, b: BitField, on index: Int) -> BitField {
        // index represnts n bits from the left, or the nth bit
        // so 31 - index gives how much I need to shift for the flag bit
        let flagIndex: Int = 31 - index
        // we will always use BitField a, the value of the index must be 1 so when subtraction occurs, flagged bits won't interfere
        let newBitField: BitField = BitField(from: a.value + 1 << flagIndex)
        let flaggedBitValue = (newBitField.value >> index) & Int32(1 << index)
        newBitField.value = (newBitField.value - flaggedBitValue) + (1 << index)
        return newBitField
    }
}

func getMintermTable(value: any Statement) -> Dictionary<Int, [Bool]> {

}