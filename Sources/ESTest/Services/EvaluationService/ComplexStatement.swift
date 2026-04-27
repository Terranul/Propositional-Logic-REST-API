class ComplexStatement: Statement {

    let rhs: any Statement
    let lhs: any Statement
    let op: any Operator
    let leadingOp: any LeadingOperator


    func evaluate(resolutionMap: [Character: Bool]) -> Bool {
        let lhsResult = lhs.evaluate(resolutionMap: resolutionMap)
        let rhsResult: Bool = rhs.evaluate(resolutionMap: resolutionMap)
        let result: Bool = op.applyOperation(lhs: lhsResult, rhs: rhsResult)
        return leadingOp.applyOperation(value: result)
    }

    init(lhs: any Statement, rhs: any Statement, op: any Operator, leadingOp: any LeadingOperator) {
        self.rhs = rhs
        self.lhs = lhs
        self.op = op
        self.leadingOp = leadingOp
    }

    func getStatement() -> String {
        return "\(leadingOp.getStringRepresentation())(\(lhs.getStatement()) \(op.getStringRepresentation()) \(rhs.getStatement()))"
    }

}