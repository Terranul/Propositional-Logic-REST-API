protocol Operator {

    func applyOperation(lhs: Bool, rhs: Bool) -> Bool
    func getStringRepresentation() -> String

    // return a statement where the negation has been applied to the operator
    // as a result the new statement should always have the default leading operator
    func negateOperator(lhs: any Statement, rhs: any Statement) -> ComplexStatement

    func getPrimitiveRepresentation(lhs: any Statement, rhs: any Statement) -> ComplexStatement

    // turns the operator in value into the Self type. May use negations to make it work out
    func coerce(on value: ComplexStatement) throws -> ComplexStatement
    
}

class AndOperator: Operator {

    func coerce(on value: ComplexStatement) throws -> ComplexStatement {
        value.simplifyLop()
        let primValue: ComplexStatement = value.op.getPrimitiveRepresentation(lhs: value.lhs, rhs: value.rhs)
        // if the primValue is an Or, we negate, otherwise leave the same
        if (primValue.op is OrOperator) {
            primValue.negate()
            primValue.simplifyLop()
            primValue.negate()
        }
        return primValue
    }


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

    func coerce(on value: ComplexStatement) throws -> ComplexStatement {
        value.simplifyLop()
        let primValue: ComplexStatement = value.op.getPrimitiveRepresentation(lhs: value.lhs, rhs: value.rhs)
        // if the primValue is an And, we negate, otherwise leave the same
        if (primValue.op is AndOperator) {
            primValue.negate()
            primValue.simplifyLop()
            primValue.negate()
        }
        return primValue
    }


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

    // (A op B) op (A op B)
    func coerce(on value: ComplexStatement) throws -> ComplexStatement {
        


        if let complxLhs: ComplexStatement = value.lhs as? ComplexStatement {
            if let complexRhs: ComplexStatement = value.rhs as? ComplexStatement {
                if (complxLhs == complxLhs.localCopy().negate().self) {

                }
            }
        }
    }


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
            lhs: ComplexStatement(lhs: lhs.copy(), rhs: rhs.copy(), op: AndOperator(), leadingOp: DefaultLeadingOperator()), 
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
        // remember, we can only reuse objects we have copied
        let lhsCpy: any Statement = lhs.copy()
        lhs.negate()
        return ComplexStatement(lhs: lhsCpy, rhs: rhs, op: OrOperator(), leadingOp: DefaultLeadingOperator())
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

func withUniqueReference(value: inout any Statement, _ operation: (any Statement) -> (any Statement)) -> any Statement {
    var conform: AnyObject = value as AnyObject
    if (isKnownUniquelyReferenced(&conform)) {
        return operation(value)
    } else {
        let copy: any Statement = value.copy()
        value = copy
        return operation(copy)
    }
}
