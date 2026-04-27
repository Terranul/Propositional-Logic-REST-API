class RawStatement: Statement {

    let lhs: Character
    let rhs: Character
    let op: any Operator

    init(lhs: Character, rhs: Character, op: any Operator) {
        self.lhs = lhs
        self.rhs = rhs
        self.op = op
    }

    func evaluate(resolutionMap: [Character: Bool]) -> Bool {
      guard let lhsEval: Bool = resolutionMap[lhs] else {
        return false
      }
      guard let rhsEval: Bool = resolutionMap[rhs] else {
        return false
      }
      return op.applyOperation(lhs: rhsEval, rhs: lhsEval)
    }

    func getStatement() -> String {
        return "(\(lhs) \(op.getStringRepresentation()) \(rhs))"
    }
}