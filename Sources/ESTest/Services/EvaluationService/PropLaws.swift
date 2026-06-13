enum StatementError: Error {
    case InvalidOperation(String)
}

/*
A suite of functions to apply logical operations to statements
Some of these are general operations, meaning they do not ensure equivalance between the input and the result

The result of these functions are not edit safe, you must use the withUniqueReference function for modfications afterwards
or call copy() on the result
*/

// general structure (a v (a ^ b)) -> (a v a) ^ (a v b)
func distribute(_ lhs: any Statement, over rhs: ComplexStatement, op: any Operator) -> ComplexStatement {
    let lhsCpy: any Statement = lhs.copy()
    let rhsCpy: any Statement = rhs.lhs.copy()
    return ComplexStatement(lhs: ComplexStatement(lhs: lhsCpy, rhs: rhsCpy, op: op, leadingOp: DefaultLeadingOperator()), 
                            rhs: ComplexStatement(lhs: lhsCpy, rhs: rhsCpy, op: op, leadingOp: DefaultLeadingOperator()), 
                            op: rhs.op, 
                            leadingOp: DefaultLeadingOperator())
}

//REQUIRES: A common statement between one side and the inner statements of the other side
//reversal of distribute
//((a ^ b) v (a ^ c)) -> a ^ (b v c)
func extract(lhs: ComplexStatement, rhs: ComplexStatement, op: any Operator) throws -> ComplexStatement {
    // we must first identify the common element, meaning we must do 4 checks
    if (lhs.op.getStringRepresentation() != rhs.op.getStringRepresentation()) {
        throw StatementError.InvalidOperation("Unable to perform extraction as the inner rhs and lhs variables are not consistent")
    }
    // towards my commitment to the mirage of existential epiphanies that shrouds humanity's true global detachment
    // if there is a leading operator on the rhs or lhs we'll bring the inwards first.
    lhs.simplifyLop()
    rhs.simplifyLop()
    var newA: (any Statement)? = nil
    var newB: (any Statement)? = nil
    var newC: (any Statement)? = nil
    if (lhs.lhs.isEqual(to: rhs.lhs)) {
        // ((a ^ b) v (a ^ c)) -> a ^ (b v c)
        newA = lhs.lhs.copy()
        newB = lhs.rhs.copy()
        newC = rhs.rhs.copy()
    } else if (lhs.lhs.isEqual(to: rhs.rhs)) {
        // ((a ^ b) v (c ^ a)) -> a ^ (b v c)
        newA = lhs.lhs.copy()
        newB = lhs.rhs.copy()
        newC = rhs.lhs.copy()
    } else if (lhs.rhs.isEqual(to: rhs.lhs)) {
        // ((a ^ b) v (b ^ c)) -> b ^ (a v c)
        newA = lhs.rhs.copy()
        newB = lhs.lhs.copy()
        newC = rhs.rhs.copy()
    } else if (lhs.rhs.isEqual(to: rhs.rhs)) {
        // ((a ^ b) v (c ^ b)) -> b ^ (a v c)
        newA = lhs.rhs.copy()
        newB = lhs.lhs.copy()
        newC = rhs.lhs.copy()
    }
    if let newA, let newB, let newC {
        return ComplexStatement(lhs: newA, 
                                rhs: ComplexStatement(lhs: newB, rhs: newC, op: op, leadingOp: DefaultLeadingOperator()),
                                op: lhs.op, 
                                leadingOp: DefaultLeadingOperator())
    } else {
       throw StatementError.InvalidOperation("No duplicate variables between lhs and rhs to apply extraction on") 
    }
}

func absorption(for statement: ComplexStatement) throws -> any Statement{
     // check both sides
     if let lhs: ComplexStatement = statement.lhs as? ComplexStatement {
        if (isValidAbsorption(lhs: statement.rhs, rhs: lhs, op: statement.op)) {
            return statement.rhs.copy()
        }
     }
     if let rhs: ComplexStatement = statement.rhs as? ComplexStatement {
        if (isValidAbsorption(lhs: statement.lhs, rhs: rhs, op: statement.op)) {
            return statement.lhs.copy()
        }
     }
    throw StatementError.InvalidOperation("Absorption law is not applicable to the statement: \(statement.getStatement())")
}

private func isValidAbsorption(lhs: any Statement, rhs: ComplexStatement, op: any Operator) -> Bool {
    return ((op is OrOperator && rhs.op is AndOperator) || (op is AndOperator && rhs.op is OrOperator)) &&
            // such a pain to get equal to look nice here so I'll just do this for now
            (lhs.isEqual(to: rhs.lhs) || lhs.isEqual(to: rhs.rhs))
}
