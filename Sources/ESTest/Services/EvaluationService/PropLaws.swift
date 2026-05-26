/*
A suite of functions to apply logical operations to statements
Some of these are general operations, meaning they do not ensure equivalance between the input and the result

The result of these functions are not edit safe, you must use the withUnqueReference function for modfications afterwards
*/

// general structure (a v (a ^ b)) -> (a v a) ^ (a v b)
func distribute(_ lhs: any Statement, over rhs: ComplexStatement, op: any Operator) -> ComplexStatement {
    return ComplexStatement(lhs: ComplexStatement(lhs: lhs, rhs: rhs.lhs, op: op, leadingOp: DefaultLeadingOperator()), 
                            rhs: ComplexStatement(lhs: lhs, rhs: rhs.rhs, op: op, leadingOp: DefaultLeadingOperator()), 
                            op: rhs.op, 
                            leadingOp: DefaultLeadingOperator())
}