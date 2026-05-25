protocol Operator {

    func applyOperation(lhs: Bool, rhs: Bool) -> Bool
    func getStringRepresentation() -> String

    // return a statement where the negation has been applied to the operator
    // as a result the new statement should always have the default leading operator
    func negateOperator(lhs: any Statement, rhs: any Statement) -> ComplexStatement

    func getPrimitiveRepresentation(lhs: any Statement, rhs: any Statement) -> ComplexStatement
    
}

class AndOperator: Operator {

    func getPrimitiveRepresentation(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
        return ComplexStatement(lhs: lhs, rhs: rhs, op: AndOperator(), leadingOp: DefaultLeadingOperator())
    }

    
    func negateOperator(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
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

    func getPrimitiveRepresentation(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
        return ComplexStatement(lhs: lhs, rhs: rhs, op: OrOperator(), leadingOp: DefaultLeadingOperator())
    }


    func negateOperator(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
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

    func negateOperator(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
        let primitive: ComplexStatement = getPrimitiveRepresentation(lhs: lhs, rhs: rhs)
        primitive.negate()
        // we need to finally remove the negation from top level
        return OrOperator().negateOperator(lhs: primitive.lhs, rhs: primitive.rhs)
    }
    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return lhs != rhs
    }

    func getStringRepresentation() -> String {
        return "#"
    }

    func getPrimitiveRepresentation(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
        // a # b = (a ^ ~b) v (~a ^ b) // return a constructed statement of this
        let minusLhs: any Statement = lhs.copy()
        minusLhs.negate()
        let minusRhs: any Statement = rhs.copy()
        minusRhs.negate()
        return ComplexStatement(
            lhs: ComplexStatement(lhs: lhs, rhs: minusRhs, op: AndOperator(), leadingOp: DefaultLeadingOperator()), 
            rhs: ComplexStatement(lhs: minusLhs, rhs: rhs, op: AndOperator(), leadingOp: DefaultLeadingOperator()), 
            op: OrOperator(), 
            leadingOp: DefaultLeadingOperator())
    }

}

class BICOperator: Operator {

    func negateOperator(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
        let primitive: ComplexStatement = getPrimitiveRepresentation(lhs: lhs, rhs: rhs)
        primitive.negate()
        // we need to finally remove the negation from top level
        return OrOperator().negateOperator(lhs: primitive.lhs, rhs: primitive.rhs)
    }

    func getPrimitiveRepresentation(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
        // a # b = (a ^ b) v (~a ^ ~b) // return a constructed statement of this
        let minusLhs: any Statement = lhs.copy()
        minusLhs.negate()
        let minusRhs: any Statement = rhs.copy()
        minusRhs.negate()
        return ComplexStatement(
            lhs: ComplexStatement(lhs: lhs, rhs: rhs, op: AndOperator(), leadingOp: DefaultLeadingOperator()), 
            rhs: ComplexStatement(lhs: minusLhs, rhs: minusRhs, op: AndOperator(), leadingOp: DefaultLeadingOperator()), 
            op: OrOperator(), 
            leadingOp: DefaultLeadingOperator())
    }

    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && rhs || !lhs && !rhs  
    }

    func getStringRepresentation() -> String {
        return "="
    }

}

class IMPOperator: Operator {
    func negateOperator(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
        let primitive: ComplexStatement = getPrimitiveRepresentation(lhs: lhs, rhs: rhs)
        primitive.negate()
        // we need to finally remove the negation from top level
        return OrOperator().negateOperator(lhs: primitive.lhs, rhs: primitive.rhs)
    }

    func getPrimitiveRepresentation(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
        lhs.negate()
        return ComplexStatement(lhs: lhs, rhs: rhs, op: OrOperator(), leadingOp: DefaultLeadingOperator())
    }

    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return !lhs || rhs
    }

    func getStringRepresentation() -> String {
        return ">"
    }

}

class NANDOperator: Operator {

    func negateOperator(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
        return ComplexStatement(lhs: lhs, rhs: rhs, op: AndOperator(), leadingOp: DefaultLeadingOperator())
    }

    func getPrimitiveRepresentation(lhs: any Statement, rhs: any Statement) -> ComplexStatement {
        lhs.negate()
        rhs.negate()
        return ComplexStatement(lhs: lhs, rhs: rhs, op: OrOperator(), leadingOp: DefaultLeadingOperator())
    }

    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return !(lhs && rhs)
    }

    func getStringRepresentation() -> String {
        return "|"
    }

}

func withUniqueReference<T: Statement & AnyObject>(value: inout T, _ operation: (any Statement) -> (T)) -> T {
    if (isKnownUniquelyReferenced(&value)) {
        return operation(value)
    } else {
        let copy: T = value.copy()
        value = copy
        return operation(copy)
    }
}
