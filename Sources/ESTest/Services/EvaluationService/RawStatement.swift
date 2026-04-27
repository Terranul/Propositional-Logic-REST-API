class RawStatement: Statement {

    let variable: Character
    let leadingOp: any LeadingOperator

    init(variable: Character, leadingOp: any LeadingOperator) {
        self.variable = variable
        self.leadingOp = leadingOp
    }

    func evaluate(resolutionMap: [Character: Bool]) -> Bool {
      guard let varEval: Bool = resolutionMap[variable] else {
        return false
      }
      return leadingOp.applyOperation(value: varEval)
    }

    func getStatement() -> String {
        return "\(leadingOp.getStringRepresentation())\(String(variable))"
    }
}