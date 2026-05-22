
/*
    Parser specifically to allow support for chaining of conditionals without brackets
    Read from right to left
    ((a^b)^(b^c)^(cve))
*/

struct groupedParser: Parser {

    func parseRHS(value: String, opIndex: DefaultIndices<String>.Element) -> String {
        let start: DefaultIndices<String>.Element = value.index(after: opIndex)
        let end: String.Index = value.index(before: value.endIndex)
        let extractedString: [Substring.Element] = Array(value[start..<end])
        // we need to be careful since the outside parens can obfuscate the leading operator
        // the only case where we have a leading operator that can be a nuisance is when we have a raw statement
        // the logic will only return false when the statement is a raw statement
        if (!(extractedString.count <= 3 && extractedString[0] == "(")) {
            return applyExtraBinding(extractedString: extractedString)
        }
        return String(extractedString)
    }

    func parseLHS(value: String, opIndex: DefaultIndices<String>.Element) -> String {
        // we know the first character must be (
        let start: String.Index = value.index(value.startIndex, offsetBy: 1)
        let end: DefaultIndices<String>.Element = opIndex
        let extractedString: [Substring.Element] = Array(value[start..<end])
        if (!(extractedString.count <= 3 && extractedString[0] == "(")) {
            return applyExtraBinding(extractedString: extractedString)
        }
        return String(extractedString)
    }

    private func applyExtraBinding(extractedString: [Substring.Element]) -> String {
        // if this is a chained statement, we must check if there are parens around it, otherwise we add them
        if (extractedString[0] != "(" && extractedString[extractedString.count - 1] != ")") {
            return "(" + String(extractedString) + ")"
        }
        return String(extractedString)
    }


    func getSplitIndex(value: String) throws -> String.Index {
        // find the first index where paren count is 0
        var parenCount = 1
        for char in value.reversed() { // reverse so that we ensure the rightmost chained operator is split
            if (char == ")") {
                parenCount -= 1
            } else if (char == "(") {
                parenCount += 1
            } else if (parenCount == 0 && operatorParser.isOperator(value: char))
            {
                return value.lastIndex(of: char)!
            }
        }
        throw EvalError.InvalidOperator(operator: "x")
    }

    func isRawStatement(value: String) -> Bool {
        return value.count <= 3 && value[value.startIndex] == "("
    }

    func parseRawStatement(value: String, lop: any LeadingOperator) throws -> RawStatement {
        return RawStatement(variable: Character(value), leadingOp: lop)
    }
}