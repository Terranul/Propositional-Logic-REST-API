public struct StatementParser {

    // parses in the form of a propositional logic statement
    // Complex statement: Multiple 

    let operatorParser: OperatorParser = OperatorParser()

    // divides a given string prop logic statement into a clear lhs, rhs, and operator
    // return a statement representing this parse
    // assumes balanced paren checks already have occurred
    func parseStatement(value: String) throws -> any Statement {
        let leadingOperator: any LeadingOperator = operatorParser.getLeadingOperator(value: value)
        let rmValue: String = operatorParser.removeLeadingOperator(value: value)
        if (isRawStatement(value: rmValue)) {
            return try parseRawStatement(variable: rmValue, leadingOp: leadingOperator)
        } else {
            guard let opIndex: DefaultIndices<String>.Element = getOperatorIndex(value: rmValue) else {
                throw EvalError.InvalidOperator(operator: "a")
            }
            return try parseComplexStatement(value: rmValue, opIndex: opIndex, leadingOp: leadingOperator)
        }
    }

    func parseComplexStatement(value: String, opIndex: DefaultIndices<String>.Element, leadingOp: any LeadingOperator) throws -> any Statement {
        let lhs: String = parseLHS(value: value, opIndex: opIndex)
        let rhs: String = parseRHS(value: value, opIndex: opIndex)
        let curOperator: any Operator = try operatorParser.getOperator(value: value[opIndex])
        return ComplexStatement(lhs: try parseStatement(value: lhs),
                                rhs: try parseStatement(value: rhs), 
                                op: curOperator,
                                leadingOp: leadingOp)
    }

    public func parseLHS(value: String, opIndex: DefaultIndices<String>.Element) -> String {
        // we know the first character must be (
        let start: String.Index = value.index(value.startIndex, offsetBy: 1)
        let end: DefaultIndices<String>.Element = opIndex
        // include start, exclude end
        print("lhs result:" + String(value[start..<end]))
        return String(value[start..<end])
    }

    public func parseRHS(value: String, opIndex: DefaultIndices<String>.Element) -> String {
        // find the beginning of the rhs
        let start: DefaultIndices<String>.Element = value.index(after: opIndex)
        let end: String.Index = value.index(before: value.endIndex)
        print("rhs result:" + String(value[start..<end]))
        return String(value[start..<end])
    }

    // default indices is a specialized type to allow indexed access into a list
    public func getOperatorIndex(value: String) -> DefaultIndices<String>.Element? {
        // the value will have multiple operators, so we will search until we have an operator and balanced parens
        var parenCount = -1 // start at -1 becuase of the leading parens
        for index in value.indices {
            if (value[index] == "(") {
                parenCount += 1
            } else if (value[index] == ")") {
                parenCount -= 1
            }
            if (operatorParser.isOperator(value: value[index]) && parenCount == 0) {
                return index
            }
        }
        return nil
    }

    // raw statement is in form "a" (single variable)
    public func isRawStatement(value: String) -> Bool {
        return value.count == 1
    }

    // undefined variable checks have occured already, the errors are just extra padding here
    func parseRawStatement(variable: String, leadingOp: any LeadingOperator) throws -> any Statement {
        let varChar: Character? = Character(variable)
        if let varChar: Character {
            return RawStatement(variable: varChar, leadingOp: leadingOp)
        } else {
            throw EvalError.InternalParsingError
        }
    }

    public func isNegated(value: String) -> Bool {
        let firstIndex: String.Index = value.startIndex
        return value[firstIndex] == "~"
    }

    // (cv(a^b))
}