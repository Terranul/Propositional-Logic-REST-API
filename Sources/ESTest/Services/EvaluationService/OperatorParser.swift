struct OperatorParser {

    let operatorSet: Set<Character> = ["^", "v"]

    public func isOperator(value: Character) -> Bool {
        return operatorSet.contains(value)
    }

    public func getOperator(value: Character) throws -> Operator {
        switch(value) {
            case "^": 
                return AndOperator()
            case "v":
                return OrOperator()
            default:
                throw EvalError.InvalidOperator(operator: value)
        }
    }
}