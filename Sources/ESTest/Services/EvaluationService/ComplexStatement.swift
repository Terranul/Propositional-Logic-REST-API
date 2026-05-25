class ComplexStatement: Statement {

    var rhs: any Statement
    var lhs: any Statement
    var op: any Operator
    var leadingOp: any LeadingOperator


    func evaluate(resolutionMap: [Character: Bool]) throws-> Bool {
        let lhsResult = try lhs.evaluate(resolutionMap: resolutionMap)
        let rhsResult: Bool = try rhs.evaluate(resolutionMap: resolutionMap)
        let result: Bool = op.applyOperation(lhs: lhsResult, rhs: rhsResult)
        return leadingOp.applyOperation(value: result)
    }

    required init(lhs: any Statement, rhs: any Statement, op: any Operator, leadingOp: any LeadingOperator) {
        self.rhs = rhs
        self.lhs = lhs
        self.op = op
        self.leadingOp = leadingOp
    }

    func copy() -> Self {
        let lhsCpy: any Statement = lhs.copy()
        let rhsCpy: any Statement = rhs.copy()

        return Self(
        lhs: lhsCpy,
        rhs: rhsCpy,
        op: op,
        leadingOp: leadingOp
    )
    }

    func getStatement() -> String {
        return "\(leadingOp.getStringRepresentation())(\(lhs.getStatement()) \(op.getStringRepresentation()) \(rhs.getStatement()))"
    }

    func toLRF() -> any Statement {

    }

    func negate() {
        self.leadingOp = leadingOp.negate()
    }

}