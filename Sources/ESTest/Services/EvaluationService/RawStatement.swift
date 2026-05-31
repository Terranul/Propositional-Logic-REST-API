class RawStatement: Statement {


    var variable: Variable
    var leadingOp: any LeadingOperator

    init(variable: Character, leadingOp: any LeadingOperator) {
        self.variable = variable
        self.leadingOp = leadingOp
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
    }

    func evaluate(resolutionMap: [Character: Bool]) throws -> Bool {
      guard let varEval: Bool = resolutionMap[variable] else {
        throw EvalError.UndefinedVariable(variable: variable)
      }
      return leadingOp.applyOperation(value: varEval)
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