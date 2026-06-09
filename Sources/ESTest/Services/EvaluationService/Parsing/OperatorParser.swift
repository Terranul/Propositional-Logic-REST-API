struct OperatorParser {

    let operatorSet: Set<Character> = ["^", "v", "#", "=", ">", "|"]
    let leadingOperatorSet: Set<Character> = ["+", "-", "~"]

    public func isOperator(value: Character) -> Bool {
        return operatorSet.contains(value)
    }

    public func isLeadingOperator(value: Character) -> Bool {
        return leadingOperatorSet.contains(value)
    }

    public func getOperator(value: Character) throws -> any Operator {
        switch(value) {
            case "^": 
                return AndOperator()
            case "v":
                return OrOperator()
            case "#":
                return XOROperator()
            case "=":
                return BICOperator()
            case ">":
                return IMPOperator()
            case "|":
                return NANDOperator()
            default:
                throw EvalError.InvalidOperator(operator: value)
        }
    }

    public func getLeadingOperator(value: Character) -> any LeadingOperator {
        switch(value) {
            case "-":
                return FalseSlashOperator()
            case "~":
                return NotOperator()
            case "+":
                return TrueSlashOperator()
            default:
                return DefaultLeadingOperator()
        }
    }

    public func removeLeadingOperator(value: String) -> String {
        if (leadingOperatorSet.contains(value[value.startIndex])) {
            return String(value.dropFirst())
        } else {
            return value
        }
    }

    public func getOperators() -> [any Operator] {
        return [OrOperator(), AndOperator(), XOROperator(), BICOperator(), NANDOperator(), IMPOperator()]
    }
}