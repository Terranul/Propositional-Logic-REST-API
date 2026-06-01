// application of Quine–McCluskey algorithm for simplifcation of prop logic statements

enum SimpErrors: Error {
    case InvalidBitMerge
}

struct BitField: Hashable {

    static let FLAG_BITS_BEGIN_INDEX: Int = 17

    /*
        Represents the T/F sequence of a given inputs to a statements
        The bits starting from the left side (one's bit) to the size of the T/F inputs it the sequence
        The bits from the last bit to the bit before the size of the T/F sequence are flag bits to represent which bits don't
        need to assume either 1 or 0. 
    */

    var value: Int32

    public init(from value: [Bool]) {
        self.value = 0
        self.value = self.convert(from: value)
    }

    public init(from value: Int32) {
        self.value = value
    }

    // good compiler
    mutating func append(position: Int) {
        value += 1 << position
    }

    func extractStatementBits() -> Int32 {
        return self.value << BitField.FLAG_BITS_BEGIN_INDEX
    }

    // debug
    func getStatementBits() -> String {
        var stringStatements: String = ""
        for i in (0..<32).reversed() {
            let shft = (value >> i) & 1
            if (shft == 0) {
                stringStatements += "0"
            } else {
                stringStatements += "1"
            }
        }
        return stringStatements
    }

    // converts sequence of bool to their binary representation: TFTF -> 1010
    private func convert(from value: [Bool]) -> Int32 {
        var target: Int32 = 0
        for i in 0..<value.count {
            if(value[i]) {
                let key: Int = value.count - i - 1
                target += 1 << key
            }
        }
        return target
    }

    // will only merge if there is exactly one different bit in the statement sequence
    // size is the number of variables (or the size of the statement sequence)
    func merge(b: BitField) throws -> BitField {
        // when we xor, we want only one single bit remaining
        let onlyStatementSequenceA: Int32 = self.value << BitField.FLAG_BITS_BEGIN_INDEX
        let onlyStatementSequenceB: Int32 = b.value << BitField.FLAG_BITS_BEGIN_INDEX
        let diffBits: Int32 = onlyStatementSequenceA ^ onlyStatementSequenceB
        // BitFields were the statement sequence is all 0's should have been filtered out preliminarily but we will still account for it
        if (diffBits == 0) {
            throw SimpErrors.InvalidBitMerge
        } else {
            if (diffBits & (diffBits - 1) == 0) {
                // bingo 
                return perfromMerge(a: self, b: b, on: (diffBits >> BitField.FLAG_BITS_BEGIN_INDEX).trailingZeroBitCount)
            } else {
                throw SimpErrors.InvalidBitMerge
            }
        }
    }

    // index is 0 based
    func perfromMerge(a: BitField, b: BitField, on index: Int) -> BitField {
        // the statement bit must be able to be lined up with the flag bits when shifted by FLAG_BITS_BEGIN_INDEX
        var newBitField: BitField = BitField(from: a.value + 1 << (BitField.FLAG_BITS_BEGIN_INDEX + index))
        let flaggedBitValue = newBitField.value & Int32(1 << index)
        if (flaggedBitValue == 0) {newBitField.append(position: index)} // all "-"" must be 1's in the statement sequence
        return newBitField
    }

    // determines if the given minterm can contain the same possible value
    // 1-00 matches 1100 and 1000
    // REQUIRES: minterm must have be a raw minterm, meaning it cannot have any merges applied
    // TODO: fix the above requires later
    func matches(with minterm: BitField) -> Bool {
        // we know they are identical if all 0's, this is better than plain == becuase we can determine where the mismatch is
        let xor: Int32 = (self.extractStatementBits() ^ minterm.extractStatementBits())
        // know the 1's in the xor will be lined up with the flag bits in self.value
        if(xor == 0) {return true}
        return (xor & self.value) > 0
    }
}

// func getMintermTable(value: any Statement) throws -> Dictionary<Int, [Bool]> {
//     let possibleOutputs: [[Character : Bool]] = EvalBridge().getAllResults(variables: Array(value.getVariables()))
//     let (variables, values): ([Character], [[Bool]]) = convertInputList(possibleOutputs)
//     let rawBitfields: Set<BitField> = getRawBitfields(values)
//     let primeImplicants: Set<BitField> = try getPrimeImplicants(minterms: rawBitfields, varCount: variables.count)



// }

func getRawBitfields(_ outcomes: [[Bool]]) -> Set<BitField> {
    return Set<BitField>(
        outcomes.map() { outcome in
            return BitField.init(from: outcome)
        })
}

func getPrimeImplicants(minterms: Set<BitField>) throws -> Set<BitField> {
    var primeImplicants: Set<BitField> = Set<BitField>()
    var numberOfMerges: Int = 0
    for a: BitField in minterms {
        for b: BitField in minterms {
            if (a != b) {
                do {
                    let merge: BitField = try a.merge(b: b)
                    primeImplicants.insert(merge)
                    numberOfMerges += 1
                } catch SimpErrors.InvalidBitMerge {
                    // unable to merge
                    continue
                }
            }
        }
    }
    if (numberOfMerges == 0) {
        // all possible merges have been completed
        return minterms
    } else {
        return try getPrimeImplicants(minterms: primeImplicants)
    }
}

// returns the inputs list as a tuple where $1 represents the order of variables, and $2 is the variable values as ordered by $1
func convertInputList(_ value: [[Character: Bool]]) -> ([Character], [[Bool]]) {
    var varList: [Character] = [] // we can infer this from the first keyset
    var boolList: [[Bool]] = []
    for eval: [Character : Bool] in value {
        if (varList.isEmpty) {
            varList = Array(eval.keys)
        }
        var inputs: [Bool] = []
        for variable: Character in varList {
           inputs.append(eval[variable]!) 
        }
        boolList.append(inputs)
    }
    return (varList, boolList)
}

func getEssentialImplicants(primeImplicants: Set<BitField>, outcomes: Set<BitField>) -> Set<BitField> {
    // future Ben: plan is to map each valid boolean outcome, to all the primeImplicants that match it
    // then we can first find the keys where there is only one value and go from there
    var essentialDict: Dictionary<BitField, Set<BitField>> = [:]
    var essentialImplicants: Set<BitField> = []
    for outcome: BitField in outcomes {
        essentialDict[outcome] = []
    }
    for outcome: BitField in outcomes {
        for prime in primeImplicants {
            if (prime.matches(with: outcome)) {
                essentialDict[outcome]!.insert(prime)
            }
        }
    }
    for key in essentialDict.keys {
        if (essentialDict[key]!.count == 1) {
            // we have found a minimal outcome
            essentialImplicants.insert(essentialDict[key]!.first!)
            essentialDict[key] = nil
        }
    }
    // do it all over again once we have found the minimal implicants
    for key in essentialDict.keys {
        // we must first figure out if this is already covered by an essential implicant
        if (!essentialDict[key]!.contains(essentialImplicants)) {
            essentialImplicants.insert(essentialDict[key]!.first!)
        }
    }
    return essentialImplicants
}