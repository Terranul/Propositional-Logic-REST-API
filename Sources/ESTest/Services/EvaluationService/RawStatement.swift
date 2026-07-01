import OrderedCollections

class RawStatement: Statement {


    var variable: Variable
    var leadingOp: any LeadingOperator
    var outcomeMatch: BitFieldSequence

    init(variable: Character, leadingOp: any LeadingOperator) {
        self.variable = variable
        self.leadingOp = leadingOp
        self.outcomeMatch = BitFieldSequence(value: BitField(from: 1073676287)) // 00111111111111101111111111111111
        self.outcomeMatch = self.leadingOp.getOutcome(self.outcomeMatch)
    }

     func getBitFieldSequence() -> BitFieldSequence {
        return outcomeMatch
    }

    func isSolved() -> Bool {
        // cannot really have a true result, the only possiblity is if lop is trueLeadingOperator
        return self.leadingOp is TrueSlashOperator
    }

    func evaluateOutcomeMatch(resolutionMap: [Character : Bool]) throws -> Bool {
        if let outcome = resolutionMap[self.variable] {
            return self.outcomeMatch.evaluate(outcome: [outcome])
        } else {
            throw EvalError.UndefinedVariable(variable: self.variable)
        }
    }

    func getVariables() -> OrderedSet<Variable> {
        return OrderedSet(arrayLiteral: variable)
    }

    private func createBitFieldSequence(bitPosition: UInt) -> BitFieldSequence {
        if (leadingOp is TrueSlashOperator) {
            return BitFieldSequence(value: BitFieldSequence.getAlwaysTrueBitField())
        } else if (self.leadingOp is FalseSlashOperator) {
            return BitFieldSequence(value: BitFieldSequence.getAlwaysFalseBitField())
        }
        let initialBitSequence: BitFieldSequence = BitFieldSequence(value: BitField(from: 1 << bitPosition))
        if (leadingOp is NotOperator) {
            self.outcomeMatch = initialBitSequence.negate()
        }
        return initialBitSequence
    }

    static func == (lhs: RawStatement, rhs: RawStatement) -> Bool {
        return lhs.getStatement() == rhs.getStatement()
    }

    func copy() -> any Statement {
        return RawStatement(variable: variable, leadingOp: leadingOp)
    }

    func setLop(lop: any LeadingOperator) {
        self.leadingOp = lop
    }
    
    func toLRF() -> any Statement {
        // already in lrf, so we can know just return self
        return self
    }

    func negate() {
        leadingOp = leadingOp.negate()
        self.outcomeMatch = self.outcomeMatch.negate()
        print("result of raw statement negation:" + self.outcomeMatch.getDebugDescription())
    }

    func evaluate(resolutionMap: [Character: Bool]) throws -> Bool {
      guard let varEval: Bool = resolutionMap[variable] else {
        throw EvalError.UndefinedVariable(variable: variable)
      }
      return leadingOp.applyOperation(value: varEval)
    }

    func simplifyLop() {}

    func isEqual(to statement: any Statement) -> Bool {
        return self.getStatement() == statement.getStatement()
    }

    func getStatement() -> String {
        return "\(leadingOp.getStringRepresentation())\(String(variable))"
    }

    func getVariables() -> Set<Variable> {
        return [self.variable]
    } 

    func toCNF() -> any Statement {
        // already in cnf -> no operator
        return self
    }
}