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

// REQUIRES: A common statement between one side and the inner statements of the other side
// reversal of distribute
// ((a ^ b) v (a ^ c)) -> a ^ (b v c)
// func extract(from value: ComplexStatement) throws -> ComplexStatement {
//     // we must first identify the common element, meaning we must do 4 checks

// }

// 