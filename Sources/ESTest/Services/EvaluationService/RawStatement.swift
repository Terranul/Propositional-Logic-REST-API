class RawStatement: Statement {

    var variable: Character
    var leadingOp: any LeadingOperator

    init(variable: Character, leadingOp: any LeadingOperator) {
        self.variable = variable
        self.leadingOp = leadingOp
    }
    
    func toLRF() -> any Statement {
        
    }

    func negate() {
        leadingOp = leadingOp.negate()
    }

    func copy() -> any Statement {
        return RawStatement(variable: self.variable, leadingOp: self.leadingOp)
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
}