class ComplexStatement: Statement {

    let rhs: any Statement
    let lhs: any Statement
    let op: Operator


    func evaluate(resolutionMap: [Character: Bool]) -> Bool {
        let lhsResult = lhs.evaluate(resolutionMap: resolutionMap)
        let rhsResult: Bool = rhs.evaluate(resolutionMap: resolutionMap)
        return op.applyOperation(lhs: lhsResult, rhs: rhsResult)
    }

    init(lhs: any Statement, rhs: any Statement, op: Operator) {
        self.rhs = rhs
        self.lhs = lhs
        self.op = op
    }

    func getStatement() -> String {
        return "(\(lhs.getStatement()) \(op.getStringRepresentation()) \(rhs.getStatement()))"
    }

}