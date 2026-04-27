public struct StatementParser {

    let operatorParser: OperatorParser = OperatorParser()

    // divides a given string prop logic statement into a clear lhs, rhs, and operator
    // return a statement representing this parse
    // assumes balanced paren checks already have occurred
    func parseStatement(value: String) throws -> any Statement {
        guard let opIndex = getOperatorIndex(value: value) else {
            throw EvalError.InvalidOperator(operator: "a")
        }
        if (isRawStatement(value: value)) {
            return try parseRawStatement(value: value, opIndex: opIndex)
        } else {
            return try parseComplexStatement(value: value, opIndex: opIndex)
        }
    }

    func parseComplexStatement(value: String, opIndex: DefaultIndices<String>.Element) throws -> any Statement {
        let lhs = parseLHS(value: value, opIndex: opIndex)
        let rhs: String = parseRHS(value: value, opIndex: opIndex)
        let curOperator = try operatorParser.getOperator(value: value[opIndex])
        return ComplexStatement(lhs: try parseStatement(value: lhs),
                                rhs: try parseStatement(value: rhs), 
                                op: curOperator)
    }

    public func parseLHS(value: String, opIndex: DefaultIndices<String>.Element) -> String {
        // we know the first character must be (
        let start = value.index(value.startIndex, offsetBy: 1)
        let end = opIndex
        // include start, exclude end
        return String(value[start..<end])
    }

    public func parseRHS(value: String, opIndex: DefaultIndices<String>.Element) -> String {
        // find the beginning of the rhs
        let start = value.index(after: opIndex)
        let end = value.index(before: value.endIndex)
        return String(value[start..<end])
    }

    // default indices is a specialized type to allow indexed access into a list
    public func getOperatorIndex(value: String) -> DefaultIndices<String>.Element? {
        // the value will have multiple operators, so we will search until we have an operator and balanced parens
        var parenCount = -1 // start at -1 becuase of the leading parens
        for index in value.indices {
            if(operatorParser.isOperator(value: value[index]) && parenCount == 0) {
                return index
            } else {
                if (value[index] == "(") {
                    print("incrementing paren count")
                    parenCount += 1
                } else if (value[index] == ")") {
                    print("decrementing paren count")
                    parenCount -= 1
                }
            }
        }
        return nil
    }

    // raw statement is in form "(a^b)"
    public func isRawStatement(value: String) -> Bool {
        return value.count == 5
    }

    // undefined variable checks have occured already, the errors are just extra padding here
    func parseRawStatement(value: String, opIndex: DefaultIndices<String>.Element) throws -> any Statement {
        let lhs: Character = value[value.index(value.startIndex, offsetBy: 1)]
        let rhs: Character = value[value.index(value.startIndex, offsetBy: 3)]
        let op: any Operator = try operatorParser.getOperator(value: value[opIndex])
        return RawStatement(lhs: lhs, rhs: rhs, op: op)
    }

    // (cv(a^b))
}