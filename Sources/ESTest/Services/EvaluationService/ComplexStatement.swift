import OrderedCollections

class ComplexStatement: Statement {

    var rhs: any Statement
    var lhs: any Statement
    var op: any Operator
    var leadingOp: any LeadingOperator
    var variables: OrderedSet<Variable>
    var outcomeMatch: BitFieldSequence
    
    func evaluate(resolutionMap: [Character: Bool]) throws-> Bool {
        let lhsResult = try lhs.evaluate(resolutionMap: resolutionMap)
        let rhsResult: Bool = try rhs.evaluate(resolutionMap: resolutionMap)
        let result: Bool = op.applyOperation(lhs: lhsResult, rhs: rhsResult)
        return leadingOp.applyOperation(value: result)
    }

    func evaluateOutcomeMatch(resolutionMap: [Character : Bool]) throws -> Bool {
        // we must first align to a list that matches the one in our variables
        var refinedOutcomes: [Bool] = []
        for variable in variables {
            if let outcome = resolutionMap[variable] {
                refinedOutcomes.append(outcome)
            } else {
                throw EvalError.UndefinedVariable(variable: variable)
            }
        }
        return outcomeMatch.evaluate(outcome: refinedOutcomes)
    }

    init(lhs: any Statement, rhs: any Statement, op: any Operator, leadingOp: any LeadingOperator) {
        self.rhs = rhs
        self.lhs = lhs
        self.op = op
        self.leadingOp = leadingOp
        self.variables = rhs.getVariables().union(lhs.getVariables())
        print("statement variable list: " + self.variables.description)
        self.outcomeMatch = BitFieldSequence(value: BitFieldSequence.getAlwaysTrueBitField())
        self.outcomeMatch = createBitFieldSequence()
        // include the lop in the outcomeMatch
        self.outcomeMatch = self.leadingOp.getOutcome(self.outcomeMatch)
        print(self.outcomeMatch.getDebugDescription() + "for statement:" + self.getStatement() + " with variable sequence: " + self.getVariables().description)
    }

    // used as an internal way to bypass the outcomeMatch initilization
    internal init(lhs: any Statement, rhs: any Statement, op: any Operator, leadingOp: any LeadingOperator, outcomeMatch: BitFieldSequence) {
        self.rhs = rhs
        self.lhs = lhs
        self.op = op
        self.leadingOp = leadingOp
        self.variables = rhs.getVariables().union(lhs.getVariables())
        self.outcomeMatch = outcomeMatch
    }

    // used as an internal way to bypass the outcomeMatch initilization
    internal init(components: [any Statement], op: any Operator, outcomeMatch: BitFieldSequence) {
         self.lhs = components[0]
        if (components.count == 2) {
            self.rhs = components[1]
        } else {
            self.rhs = ComplexStatement.buildStatement(components: components, op: op, index: 1)
        }
        self.op = op
        self.leadingOp = DefaultLeadingOperator()
        self.variables = lhs.getVariables().intersection(rhs.getVariables())
        self.outcomeMatch = outcomeMatch
    }

    // everything will have been init, so it is fine to use self properties here to construct the outcomeMatch
    public func createBitFieldSequence() -> BitFieldSequence {
        print("hit create sequence")
        // add space akin to the number of distinct variables in rhs
        let (lhsOutcome, rhsOutcome) = ComplexStatement.arrangeVariables(lhs: self.lhs, rhs: self.rhs)
        if (self.op is OrOperator) {
            return lhsOutcome.union(with: rhsOutcome)
        } else if (self.op is AndOperator) {
            return lhsOutcome.intersect(with: rhsOutcome)
        } else {
            return self.op.getPrimitiveRepresentation(lhs: self.lhs, rhs: self.rhs).outcomeMatch
        }
    }

    // modifies both the incoming study and self, which is a bit wonky but whatever
     static func arrangeVariables(lhs: any Statement, rhs: any Statement) -> (BitFieldSequence, BitFieldSequence) {
        let lhsOutcome: BitFieldSequence = lhs.getBitFieldSequence().copy()
        let lhsVariables: OrderedSet<Variable> = lhs.getVariables()
        let rhsOutcome: BitFieldSequence = rhs.getBitFieldSequence().copy()
        let rhsVariables: OrderedSet<Variable> = rhs.getVariables()
        let masterSequence: OrderedSet<Variable> = rhsVariables.union(lhsVariables)
        print("arrange variables sequence: " + masterSequence.description)
        rhsOutcome.map() { bitfield in
            return ComplexStatement.rearrangeStudyBitField(
                bitfield: bitfield, studyVariables: rhsVariables, masterSequence: masterSequence)
        }
        lhsOutcome.map({ bitfield in
            return ComplexStatement.rearrangeStudyBitField(
                bitfield: bitfield, studyVariables: lhsVariables, masterSequence: masterSequence)
        })
        return (lhsOutcome, rhsOutcome)
    }

    static func rearrangeStudyBitField(
        bitfield: BitField, studyVariables: OrderedSet<Variable>,
        masterSequence: OrderedSet<Variable>
    ) -> BitField {
        var newBitField: BitField = BitField(from: bitfield.value)
        // either you stay in the position or you move leftwards, so we reverse to avoid conflicts
        for i in (0..<studyVariables.count).reversed() {
            let targetVariable: Variable = studyVariables[i]
            let newPosition = masterSequence.firstIndex(of: targetVariable)!
            newBitField.move(from: i, to: newPosition)
        }
        return newBitField
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
        self.outcomeMatch = BitFieldSequence(value: BitFieldSequence.getAlwaysTrueBitField())
        self.outcomeMatch = createBitFieldSequence()
        self.outcomeMatch = self.leadingOp.getOutcome(self.outcomeMatch)
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

    func localCopy() -> ComplexStatement {
        return ComplexStatement(lhs: self.lhs, rhs: self.rhs, op: self.op, leadingOp: self.leadingOp)
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
        self.outcomeMatch = outcomeMatch.negate()
    }

    func setLop(lop: any LeadingOperator) {
        self.leadingOp = lop
    }

    func simplifyLop() {
        let refinedStatement: any Statement = self.leadingOp.pushInward(lhs: &lhs, rhs: &rhs, op: self.op)
        if let complxSelf = refinedStatement as? ComplexStatement {
            self.overwrite(value: complxSelf)
        } else {
            // return without doing anything
            // TODO: figure out what to do here
        }
    }

    func isSolved() -> Bool {
        return self.outcomeMatch.isSolved()
    }   

     func isEqual(to statement: any Statement) -> Bool {
        return self.getStatement() == statement.getStatement()
    }


    static func == (lhs: ComplexStatement, rhs: ComplexStatement) -> Bool {
        return lhs.getStatement() == rhs.getStatement()
    }

    // getters

    func getVariables() -> OrderedSet<Variable> {
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

    func getBitFieldSequence() -> BitFieldSequence {
        return self.outcomeMatch
    }   

}