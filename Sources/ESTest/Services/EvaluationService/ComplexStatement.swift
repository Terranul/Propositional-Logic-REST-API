class ComplexStatement: Statement {

    var rhs: any Statement
    var lhs: any Statement
    var op: any Operator
    var leadingOp: any LeadingOperator
    var variables: Set<Variable>
    
    func evaluate(resolutionMap: [Character: Bool]) throws-> Bool {
        let lhsResult = try lhs.evaluate(resolutionMap: resolutionMap)
        let rhsResult: Bool = try rhs.evaluate(resolutionMap: resolutionMap)
        let result: Bool = op.applyOperation(lhs: lhsResult, rhs: rhsResult)
        return leadingOp.applyOperation(value: result)
    }

    init(lhs: any Statement, rhs: any Statement, op: any Operator, leadingOp: any LeadingOperator) {
        self.rhs = rhs
        self.lhs = lhs
        self.op = op
        self.leadingOp = leadingOp
        self.variables = lhs.getVariables().union(rhs.getVariables())
    }

    // init from a list of components with a shared operator
    // meant to replicate (a ^ b ^ c ^ d)
    // default leading operator used in the final statement -> (a ^ (b ^ (c ^ d)))
    init(components: [any Statement], op: any Operator) {
        self.lhs = components[0]
        if (components.count == 2) {
            self.rhs = components[1]
        } else {
            self.rhs = ComplexStatement.buildStatement(components: components, op: op, index: 1)
        }
        self.op = op
        self.leadingOp = DefaultLeadingOperator()
        self.variables = lhs.getVariables().intersection(rhs.getVariables())
    }

    private static func buildStatement(components: [any Statement], op: any Operator, index: Int)
        -> ComplexStatement
    {
        if (index == components.count - 2) {
            return ComplexStatement(
                lhs: components[components.count - 2], rhs: components[components.count - 1], op: op, leadingOp: DefaultLeadingOperator())
        } else {
            return ComplexStatement(
                lhs: components[index],
                rhs: ComplexStatement.buildStatement(
                    components: components, op: op, index: index + 1),
                op: op,
                leadingOp: DefaultLeadingOperator())
        }
    }

    // ((a ^ b) v (d ^ c))  -> 

    func toCNF() -> any Statement {
        self.lhs = lhs.toCNF()
        self.rhs = rhs.toCNF()
        if (op is OrOperator) {
            // distribution applies
            if let complexLhs: ComplexStatement = self.lhs as? ComplexStatement, complexLhs.op is AndOperator {
                let result: ComplexStatement = distribute(self.rhs, over: complexLhs, op: self.op)
                return result.toCNF()
            }
            if let complexRhs: ComplexStatement = self.rhs as? ComplexStatement, complexRhs.op is AndOperator {
                let result: ComplexStatement = distribute(self.rhs, over: complexRhs, op: self.op)
                return result.toCNF()
            }
            // both are RawStatements binded by an or, all is fine
            return self
        }
        return self
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
            // still may be a chance the operator is not normalized to AND/OR
            let norm: ComplexStatement = self.op.getPrimitiveRepresentation(lhs: self.lhs, rhs: self.rhs)
            // the primitive representations will always have defaultLeadingOperator
            let lrflhs: any Statement = norm.lhs.toLRF()
            let lrfrhs: any Statement = norm.rhs.toLRF()
            return ComplexStatement(lhs: lrflhs, rhs: lrfrhs, op: norm.op, leadingOp: DefaultLeadingOperator())
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

    static func == (lhs: ComplexStatement, rhs: ComplexStatement) -> Bool {
        return lhs.getStatement() == rhs.getStatement()
    }

    // getters

    func getVariables() -> Set<Variable> {
        return self.variables
    }   

    func getOperator() -> any Operator {
        return op
    }

    private func overwrite(value: ComplexStatement) {
        self.leadingOp = value.leadingOp
        self.lhs = value.lhs
        self.rhs = value.rhs
        self.op = value.op
    }

}