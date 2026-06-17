// // an extrapolation of my idea for a faster parser

// class Stack<T> {

//     var internalStack: Array<T>

//     init() {
//         internalStack = []
//     }

//     func push(_ value: T) {
//         internalStack.append(value)
//     }

//     func pop() -> T? {
//         return internalStack.removeLast()
//     }

//     func peek() -> T? {
//         return internalStack.last
//     }
// }

// let operatorParser = OperatorParser()

// func linearParse(input: String) throws -> any Statement {
//     let stack: Stack<any Statement> = Stack()
//     for character in input {
//         if (character == "(") {
//             stack.push(getComplexStatement())
//         } else if (character == ")") {
//             if let newValue = stack.pop() {
//                 fillStatement(stack.peek()! as! ComplexStatement, with: newValue)
//             }
//         } else if (operatorParser.isOperator(value: character)) {
//             if let complx: ComplexStatement = stack.peek() as? ComplexStatement {
//                 complx.op = try operatorParser.getOperator(value: character)
//             } else {
//                 // error thrown
//             }
//         } else if (operatorParser.isLeadingOperator(value: character)) {
//             stack.peek()!.setLop(lop: operatorParser.getLeadingOperator(value: character))
//         } else {
//             // we have a variable 
//             fillStatement(stack.peek()! as! ComplexStatement, with: RawStatement(variable: character, leadingOp: DefaultLeadingOperator()))
//         }
//     }
// }

// fileprivate func getComplexStatement() -> ComplexStatement {
//     let dummyRawStatement: RawStatement = RawStatement(variable: "v", leadingOp: DefaultLeadingOperator())
//     return ComplexStatement(lhs: dummyRawStatement, rhs: dummyRawStatement, op: AndOperator(), leadingOp: DefaultLeadingOperator())
// }

// fileprivate func fillStatement(_ value: ComplexStatement, with fillee: any Statement) {
//     // we will use the variable being "v" to mark that the position has yet to be filled
//     // a "v" variable is impossible to be acheived as it is a operator keyword
//     // this will need to be modified later when we add operator mapping
//     if (value.lhs.getVariables()[0] == "v") {
//         value.lhs = fillee
//     } else {
//         value.rhs = fillee
//     }
// }   