/*
    The user can select different syntaxes, so we'll use a sort of strategy pattern to implement
    a way to parse these into the standard Statement format
*/


protocol Parser {

    // Return the string index where you would like the statement to be split into seperate statement objects
    // this should be the location of the operator
    func getSplitIndex(value: String) throws -> String.Index

    func parseLHS(value: String, opIndex: DefaultIndices<String>.Element) -> String

    func parseRHS(value: String, opIndex: DefaultIndices<String>.Element) -> String

    // True when value is a raw statement(it can be evaluated by going left to right)
    func isRawStatement(value: String) -> Bool

    // return a raw statement given a value that satisfied isRawStatement
    func parseRawStatement(value: String, lop: any LeadingOperator) throws -> RawStatement

}

extension Parser {

    var operatorParser: OperatorParser {return OperatorParser()}

    // divides a given string prop logic statement into a clear lhs, rhs, and operator
    // return a statement representing this parse
    // assumes balanced paren checks already have occurred
    func parseStatement(value: String) throws -> any Statement {
        guard value != "" else {
            throw EvalError.MalformedStatement
        }
        let leadingOperator: any LeadingOperator = getLeadingOperator(value: value)
        let rmValue: String = removeLeadingOperator(value: value, lop: leadingOperator)
        if (isRawStatement(value: rmValue)) {
            return try parseRawStatement(value: rmValue, lop: leadingOperator)
        } else {
            let opIndex: DefaultIndices<String>.Element = try getSplitIndex(value: value)
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
        return String(value[start..<end])
    }

    public func parseRHS(value: String, opIndex: DefaultIndices<String>.Element) -> String {
        // find the beginning of the rhs
        let start: DefaultIndices<String>.Element = value.index(after: opIndex)
        let end: String.Index = value.index(before: value.endIndex)
        return String(value[start..<end])
    }

    private func getLeadingOperator(value: String) -> any LeadingOperator {
        let opParser: OperatorParser = OperatorParser()
        let lopList: [any LeadingOperator] = value.prefix(while: { opParser.isLeadingOperator(value: $0) })
        .map { opParser.getLeadingOperator(value: $0) }
        if (lopList.isEmpty) {
            return DefaultLeadingOperator()
        } else if (lopList.count > 1) {
            return ComplexLeadingOperator(guts: lopList)
        } else {
            return lopList[0]
        }
    }

    private func removeLeadingOperator(value: String, lop: any LeadingOperator) -> String{
        return String(value.dropFirst(lop.getLength()))
    }
}