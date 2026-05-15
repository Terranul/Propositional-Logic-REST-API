extension Array {
    
    func access(index value: Int) -> Element? {
        guard value < self.count && value >= 0 else {
            return nil
        }
        return self[value]
    }
}
/* 
   this represents an optimized but less exact version of the parser used for evaluation that only determines
   if we have a valid statement. It is meant to traverse the statement exactly once

   Central validation rules:
   - total #operators is one less than total #variables (not including leading operators)
   - Balanced Paranthesis
   - An variable must directly precede every operator, and a leading operator or variable must proceed every operator
   - #variables <= #parens except for statements without an operator (excluding leading operators)
*/

fileprivate typealias Op = Character
fileprivate typealias Variable = Character
fileprivate typealias LeadingOp = Character
fileprivate typealias Binding = Character // both ( and ) parens

struct StatementCounts {
    var op: Int = 0
    var variable: Int = 0
    var lop: Int = 0
    var bind: Int = 0

}

func validateStatement(for statement: String) -> [any Error] {
    var issues: [any Error] = []
    let statArr: [Character] = Array(statement)
    var tracker: StatementCounts = StatementCounts()
    for i in 0..<statement.count {
        let cur: Character = statArr[i]
        let next: Character? = statArr.access(index: i + 1)
        let prev: Character? = statArr.access(index: i - 1)
        if (!applyOperatorRule(opp: cur, prev: prev, next: next)) {
            print("adding invalid operator")
            issues.append(EvalError.InvalidOperator(operator: cur))
        }
        if (cur == "(") {tracker.bind += 1; continue;}
        if (cur == ")") {tracker.bind -= 1; continue;}
        if (isVariable(value: cur)) {tracker.variable += 1; continue}
        if (OperatorParser().isLeadingOperator(value: cur)) {tracker.lop += 1; continue}
        if (OperatorParser().isOperator(value: cur)) {tracker.op += 1; continue}
    }
    if (tracker.op != tracker.variable - 1) {
        print("adding  malformed from tracker - 1 rule")
        issues.append(EvalError.MalformedStatement)
    }
    if (tracker.bind != 0) {
        print("adding  unbalanced parens")
        issues.append(ValidationError.UnbalancedParens(""))
    }
    if (tracker.op != 0 && tracker.variable > tracker.bind) {
        print("adding  malformed from tracker variable AND BINSINF RULE")
        issues.append(EvalError.MalformedStatement)
    }
    return issues
}

fileprivate func applyOperatorRule(opp: Op, prev: Character?, next: Character?) -> Bool {
    let op = OperatorParser()
    if(!op.isOperator(value: opp)){return true}
    if let prev: Character, let next: Character {
        return isVariable(value: prev) && (op.isLeadingOperator(value: next) || isVariable(value: next))
    }
    return false
}

fileprivate func isVariable(value: Character) -> Bool {
    let parser = OperatorParser()
    return !parser.isLeadingOperator(value: value) && !parser.isOperator(value: value) &&
           !isBinding(value: value)
}

fileprivate func isBinding(value: Character) -> Bool {
    return value == ")" || value == "("
}