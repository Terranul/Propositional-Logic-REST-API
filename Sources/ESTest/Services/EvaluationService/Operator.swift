protocol Operator {

    func applyOperation(lhs: Bool, rhs: Bool) -> Bool
    func getStringRepresentation() -> String

    // return a statement where the negation has been applied to the operator
    // as a result the new statement should always have the default leading operator
    func negateOperator(lhs: ComplexStatement, rhs: ComplexStatement) -> ComplexStatement
    
}

class AndOperator: Operator {
    
    func negateOperator(lhs: ComplexStatement, rhs: ComplexStatement) -> ComplexStatement {
        lhs.negate()
        rhs.negate()
        return ComplexStatement(lhs: lhs, rhs: rhs, op: OrOperator(), leadingOp: DefaultLeadingOperator())
    }

    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && rhs
    }

    func getStringRepresentation() -> String {
        return "^"
    }
    
}

class OrOperator: Operator {

    func negateOperator(lhs: ComplexStatement, rhs: ComplexStatement) -> ComplexStatement {
        lhs.negate()
        rhs.negate()
        return ComplexStatement(lhs: lhs, rhs: rhs, op: AndOperator(), leadingOp: DefaultLeadingOperator())
    }
    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return lhs || rhs
    }

    func getStringRepresentation() -> String {
        return "v"
    }

}

class XOROperator: Operator {

    func negateOperator(lhs: ComplexStatement, rhs: ComplexStatement) -> ComplexStatement {
        // a # b = (a ^ ~b) v (~a ^ b) // return a constructed statement of this
        let minusLhs = lhs.copy()
        minusLhs.negate()
        let minusRhs = rhs.copy()
        minusRhs.negate()
        // use DefaultLeadingOperator() to specify no leading operator and NotOperator() to specify negation
        // OrOperator() and AndOperator()
        let newLhs = ComplexStatement(lhs: any Statement, rhs: any Statement, op: any Operator, leadingOp: any LeadingOperator)
    }
    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return lhs != rhs
    }

    func getStringRepresentation() -> String {
        return "#"
    }

}

class BICOperator: Operator {
    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && rhs || !lhs && !rhs  
    }

    func getStringRepresentation() -> String {
        return "="
    }

}

class IMPOperator: Operator {
    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return !lhs || rhs
    }

    func getStringRepresentation() -> String {
        return ">"
    }

}

class NANDOperator: Operator {
    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return !(lhs && rhs)
    }

    func getStringRepresentation() -> String {
        return "|"
    }

}
