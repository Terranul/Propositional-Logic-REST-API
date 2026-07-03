// an extrapolation of my idea for a faster parser

fileprivate class DummyStatement {
    var lhs: (any Statement)?
    var rhs: (any Statement)?
    var variable: Variable?
    var op: (any Operator)?
    var lop: [any LeadingOperator]
    var isPremature: Bool

    // init for raw statement
    init(variable: Variable, lop: any LeadingOperator) {
        self.variable = variable
        self.lop = [lop]
        self.isPremature = false
    }

    init(isPremature: Bool) {
        self.lop = []
        self.isPremature = isPremature
    }

    func create() -> any Statement {
        let resolvedLop: any LeadingOperator = lop.count == 0 ? DefaultLeadingOperator() : ComplexLeadingOperator(guts: lop)
        if (rhs == nil && variable != nil) {
            // we'll classify this as a raw statement
            return RawStatement(variable: variable!, leadingOp: resolvedLop)
        }
        return LazyEvalComplexStatement(lhs: lhs!, rhs: rhs!, op: op!, leadingOp: resolvedLop)
    }

    func createRaw(variable: Variable) -> RawStatement {
        let resolvedLop: any LeadingOperator = lop.count == 0 ? DefaultLeadingOperator() : ComplexLeadingOperator(guts: lop)
        return RawStatement(variable: variable, leadingOp: resolvedLop)
    }

    func isComplete() -> Bool {
        return lhs != nil && rhs != nil
    }

    func fill(with value: any Statement) throws{
        if (lhs == nil) {
            lhs = value
        } else if (rhs == nil) {
            rhs = value
        } else {
            // we have > 2 variables between two paren blocks ex: (aa^zb)
            // realistically, this class should be more seperated from the parser -> job for later
            throw EvalError.MalformedStatement(
                message: "More than two variables are present in this statement block: \(lhs!.getStatement() + op!.getStringRepresentation())"
            )
        }
    }   
}

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
    let stack: Stack<DummyStatement> = Stack()
    for character in input {
        if (character == "(") {
            if (stack.peek() != nil) {
                if (!stack.peek()!.isPremature) {
                    stack.push(DummyStatement(isPremature: false))
                } else {
                    stack.peek()!.isPremature = false
                }
            } else {
                stack.push(DummyStatement(isPremature: false))
            }
        } else if (character == ")") {
            if let newStatement = stack.pop()?.create() {
                if let fillStatement = stack.peek() {
                    try fillStatement.fill(with: newStatement)
                } else {
                    return newStatement
                }
            }
        } else if (operatorParser.isOperator(value: character)) {
            if let curStatement = stack.peek() {
                curStatement.op = try operatorParser.getOperator(value: character)
            } else {
                // throw error
            }
        } else if (operatorParser.isLeadingOperator(value: character)) {
            // prematurely throw onto the stack
            if (stack.peek() != nil && stack.peek()!.isPremature) {
                // case where we have chained lops
                stack.peek()!.lop.append(operatorParser.getLeadingOperator(value: character))
            } else {
                let newStatement = DummyStatement(isPremature: true)
                newStatement.lop = [operatorParser.getLeadingOperator(value: character)]
                stack.push(newStatement)
            }
        } else {
            // variable
            var newRaw: RawStatement? = nil
            if (stack.peek() != nil && stack.peek()!.isPremature) {
                newRaw = stack.pop()!.createRaw(variable: character)
            } else {
                newRaw = RawStatement(variable: character, leadingOp: DefaultLeadingOperator())
            }
            if let curStatement = stack.peek() {
                try curStatement.fill(with: newRaw!)
            } else {
                return newRaw!
            }
        }
    }
    // should never hit this point
    throw EvalError.InternalParsingError
}