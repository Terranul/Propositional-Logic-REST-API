// application of Quine–McCluskey algorithm for simplifcation of prop logic statements

enum SimpErrors: Error {
    case InvalidBitMerge
}

struct BitField: Hashable {

    static let FLAG_BITS_BEGIN_INDEX: Int = BitField.BIT_COUNT/2
    static let BIT_COUNT: Int = 32

    /*
        Represents the T/F sequence of a given inputs to a statements
        The bits starting from the left side (one's bit) to the size of the T/F inputs it the sequence
        The bits from the last bit to the bit before the size of the T/F sequence are flag bits to represent which bits don't
        need to assume either 1 or 0. 
    */

    var value: Int32

    public init(from value: [Bool], inOrder: Bool) {
        self.value = 0
        self.value = self.convert(from: value, inOrder: inOrder)
    }

    public init(from value: Int32) {
        self.value = value
    }

    // overflow opportunity, but luckily only I will be touching this init
    public init(statementBits: Int32, flagBits: Int32) {
        self.value = statementBits + (flagBits << BitField.FLAG_BITS_BEGIN_INDEX)
    }

    // good compiler
    mutating func append(position: Int) {
        self.value |= (1 << position)
    }

    mutating func appendStar(position: Int) {
        let flagPosition = BitField.FLAG_BITS_BEGIN_INDEX + position
        self.append(position: position)
        self.append(position: flagPosition)
    }

    mutating func deleteStar(position: Int) {
        let flagPosition = BitField.FLAG_BITS_BEGIN_INDEX + position
        self.delete(position: flagPosition)
    }

    // adds 0 at given position
    mutating func delete(position: Int) {
        self.value &= ~(1 << position)
    }

    // adds 0 at the from position and overrides any values at the destination
    // moves the flag and statement bit pair
    mutating func move(from initPosition: Int, to destination: Int) {
        guard initPosition != destination else {
            return
        }
        let flagInitPosition = BitField.FLAG_BITS_BEGIN_INDEX + initPosition
        let flagDestination: Int = BitField.FLAG_BITS_BEGIN_INDEX + destination
        let statementValue = (self.value >> initPosition) & 1
        let flagValue = (self.value >> flagInitPosition) & 1
        self.delete(position: initPosition)
        self.delete(position: flagInitPosition)
        if (statementValue == 1) {
            self.append(position: destination)
        } else {
            self.delete(position: destination)
        }
        if (flagValue == 1) {
            self.append(position: flagDestination)
        } else {
            self.delete(position: flagDestination)
        }
        // now place a star at the old site
        self.appendStar(position: initPosition)
    }

    // there is currently a pretty critical bug becuase we don't use unsigned Int and we shift left when supporting max (16) variables
    // we would get ones instead of zeroes
    // this is unlikely to happen in my testing, and I'm only ever going to be using this so...
    func extractStatementBits() -> Int32 {
        return self.value << BitField.FLAG_BITS_BEGIN_INDEX
    }

    func extractFlagBits() -> Int32 {
        return Int32(bitPattern: UInt32(bitPattern: self.value) >> BitField.FLAG_BITS_BEGIN_INDEX)
    }

    func removeFlagBits() -> Int32 {
        self.value & 65535
    }

    func doesContainFlagBit() -> Bool {
        return self.extractFlagBits() > 0
    }

    func isFlagBit(index: Int) -> Bool {
        let flagBits: Int32 = self.extractFlagBits()
        return (flagBits >> index) & 1 == 1
    }  

    func getBit(index: Int) -> Int32 {
        return (self.value >> index) & 1
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

    // inOrder is true:  [true, false, true, false]-> 1010
    // inOrder is false: [true, false, true, false] -> 0101
    private func convert(from value: [Bool], inOrder: Bool) -> Int32 {
        var target: Int32 = 0
        for i in 0..<value.count {
            guard value[i] else { continue }
            let bit = inOrder ? value.count - i - 1 : i
            target |= 1 << bit
        }               
        return target
    }

    // will only merge if there is exactly one different bit in the statement sequence
    // size is the number of variables (or the size of the statement sequence)
    func merge(b: BitField) throws -> BitField {
        // when we xor, we want only one single bit remaining
        let diffStatBits: Int32 = self.extractStatementBits() ^ b.extractStatementBits()
        let diffFlagBits: Bool = self.extractFlagBits() == b.extractFlagBits()
        // BitFields were the statement sequence is all 0's should have been filtered out preliminarily but we will still account for it
        if (diffStatBits == 0) {
            throw SimpErrors.InvalidBitMerge
        } else {
            if (diffStatBits & (diffStatBits - 1) == 0 && diffFlagBits) {
                // bingo 
                return perfromMerge(a: self, b: b, on: (diffStatBits >> BitField.FLAG_BITS_BEGIN_INDEX).trailingZeroBitCount)
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
        let xor: Int32 = (self.removeFlagBits() ^ minterm.removeFlagBits())
        // know the 1's in the xor will be lined up with the flag bits in self.value
        if(xor == 0) {return true}
        return (xor & self.extractFlagBits()) == xor
    }

    func negate() -> BitField {
        // flipping the statement bits will negate
        // we must make sure not to flip the star and flag bits though
        let flippedStatementBits: Int32 = ~self.removeFlagBits() & 65535
        // now we can make all the flag bits zero and then re-add them back
        let newStatementBits = flippedStatementBits | self.extractFlagBits()
        return BitField(from: newStatementBits + (self.extractFlagBits() << BitField.FLAG_BITS_BEGIN_INDEX))
        // let newStatementBits: Int32 = (~self.extractFlagBits() ^ flippedStatementBits) + self.extractFlagBits()
        // return BitField(from: newStatementBits + (self.extractFlagBits() << BitField.FLAG_BITS_BEGIN_INDEX))
    }

    // returns the number of variables (the number of flag bits that are zero)
    func countVariables() -> Int {
        let flagBits = self.extractFlagBits()
        var varCount = 0
        for i: Int in 0..<16 {
           let result = (flagBits >> i) & 1
           if (result == 0) {
            varCount += 1
           }
        }
        return varCount
    }

    func getVariableIndices() -> Set<Int> {
        var indices: Set<Int> = []
        for i in 0..<16 {
            if(!self.isFlagBit(index: i)) {
                indices.insert(i)
            }
        }
        return indices
    }

    // each bitfield can be mapped to a single statement
    func getStatement(variableMap: [Variable]) throws -> any Statement{
        let curVarCount = self.countVariables()
        guard curVarCount == variableMap.count else {
            throw EvalError.UndefinedVariable(variable: "/")
        }
        var intersectionSet: [RawStatement] = []
        for i in 0..<curVarCount {
            let curBit = self.getBit(index: i)
            let targetVariable: Variable = variableMap[i]
            if (curBit == 0) {
                intersectionSet.append(RawStatement(variable: targetVariable, leadingOp: NotOperator()))
            } else {
                intersectionSet.append(RawStatement(variable: targetVariable, leadingOp: DefaultLeadingOperator()))
            }
        }
        return LazyEvalComplexStatement(components: intersectionSet, op: AndOperator())
    }
}


func getEssentialImplicants(value: any Statement) throws -> ([Character], Set<BitField>) {
    var possibleOutputs: [[Character : Bool]] = EvalBridge().getAllResults(variables: Array(value.getVariables()))
    possibleOutputs = possibleOutputs.filter { output in
        do {
            // should be optimized later on
            return try value.evaluate(resolutionMap: output)
        } catch {
            return false
        }
    }
    let (variables, values): ([Character], [[Bool]]) = convertInputList(possibleOutputs)
    let rawBitfields: Set<BitField> = getRawBitfields(values)
    let primeImplicants: Set<BitField> = try getPrimeImplicants(minterms: rawBitfields)
    return (variables, getEssentialImplicants(primeImplicants: primeImplicants, outcomes: rawBitfields))
}

func getRawBitfields(_ outcomes: [[Bool]]) -> Set<BitField> {
    return Set<BitField>(
        outcomes.map() { outcome in
            return BitField.init(from: outcome, inOrder: true)
        })
}

func getPrimeImplicants(minterms: Set<BitField>) throws -> Set<BitField> {
    print("New Iteration bitch ------")
    var primeImplicants: Set<BitField> = Set<BitField>()
    var merged: Dictionary<BitField, Bool> = Dictionary(uniqueKeysWithValues: minterms.map {($0, false)})
    var numberOfMerges: Int = 0
    for a: BitField in minterms {
        for b: BitField in minterms {
            print("------------------------------")
            if (a != b) {
                print("attempting merge between a: \(a.getStatementBits()) and b: \(b.getStatementBits())")
                do {
                    let merge: BitField = try a.merge(b: b)
                    if (!primeImplicants.contains(merge)) {
                        primeImplicants.insert(merge)
                        merged[a] = true
                        merged[b] = true
                        numberOfMerges += 1
                        print("merge successful with merge being: \(merge.getStatementBits())")
                    }
                } catch SimpErrors.InvalidBitMerge {
                    // unable to merge
                    print("merge denied")
                    continue
                }
            }
        }
    }
    if (numberOfMerges == 0) {
        // all possible merges have been completed
        return minterms
    } else {
        for key: BitField in merged.keys {
            if (!merged[key]!) {
                primeImplicants.insert(key)
            }
        }
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
                print("found a match between \(prime.getStatementBits()) and \(outcome.getStatementBits())")
                print("------------------------------")
                essentialDict[outcome]!.insert(prime)
            }
        }
    }
    for key in essentialDict.keys {
        if (essentialDict[key]!.count == 1) {
            // we have found a minimal outcome
            print("found a minimal outcome for \(key.getStatementBits())")
            print("------------------------------")
            essentialImplicants.insert(essentialDict[key]!.first!)
            essentialDict[key] = nil
        }
    }
    // do it all over again once we have found the minimal implicants
    for key in essentialDict.keys {
        // we must first figure out if this is already covered by an essential implicant
        if (!essentialDict[key]!.contains(essentialImplicants)) {
            print("found a non minimal implicant with \(essentialDict[key]!.first!.getStatementBits())")
            essentialImplicants.insert(essentialDict[key]!.first!)
        }
    }
    print(essentialImplicants.description)
    return essentialImplicants
}