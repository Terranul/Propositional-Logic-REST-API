// an extrapolation of my idea for a faster parser

class Stack<T> {

    var internalStack: Array<T>

    init() {
        internalStack = []
    }

    func push(_ value: T) {
        internalStack.append(value)
    }

    func pop() -> T? {
        return internalStack.removeLast()
    }

    func peek() -> T? {
        return internalStack.last
    }
}

let operatorParser = OperatorParser()

func linearParse(input: String) throws -> any Statement {
    let stack: Stack<any Statement> = Stack()
    for character in input {
        if (character == "(") {
            stack.push(getComplexStatement())
        } else if (character == ")") {
            _ = stack.pop()
        } else if (operatorParser.isOperator(value: character)) {
            if let complx: ComplexStatement = stack.peek() as? ComplexStatement {
                complx.op = try operatorParser.getOperator(value: character)
            } else {
                // error thrown
            }
        } else if (operatorParser.isLeadingOperator(value: character)) {
            stack.peek()!.setLop(lop: operatorParser.getLeadingOperator(value: character))
        } else {
            
        }
    }
}

fileprivate func getComplexStatement() -> ComplexStatement {
    let dummyRawStatement: RawStatement = RawStatement(variable: "d", leadingOp: DefaultLeadingOperator())
    return ComplexStatement(lhs: dummyRawStatement, rhs: dummyRawStatement, op: AndOperator(), leadingOp: DefaultLeadingOperator())
}