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


    // ((a ^ b) v (d ^ c))  -> 

    func toCNF() -> any Statement {
        
    }

    func copy() -> any Statement {
        let lhsCpy: any Statement = lhs.copy()
        let rhsCpy: any Statement = rhs.copy()

        return ComplexStatement(
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
        if (leadingOp is DefaultLeadingOperator) {
            let lrflhs: any Statement = lhs.toLRF()
            let lrfrhs: any Statement = rhs.toLRF()
            return ComplexStatement(lhs: lrflhs, rhs: lrfrhs, op: self.op, leadingOp: DefaultLeadingOperator())
        } else {
            return leadingOp.pushInward(lhs: &self.lhs, rhs: &self.rhs, op: self.op).toLRF()
        }
    }

    func negate() {
        self.leadingOp = leadingOp.negate()
    }

    func setLop(lop: any LeadingOperator) {
        self.leadingOp = lop
    }


    // getters

    func getOperator() -> any Operator {
        return op
    }

}