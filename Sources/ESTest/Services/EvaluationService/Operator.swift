protocol Operator {

    func applyOperation(lhs: Bool, rhs: Bool) -> Bool
    func getStringRepresentation() -> String
    
}

class AndOperator: Operator {
    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return lhs && rhs
    }

    func getStringRepresentation() -> String {
        return "^"
    }
    
}

class OrOperator: Operator {
    
    func applyOperation(lhs: Bool, rhs: Bool) -> Bool {
        return lhs || rhs
    }

    func getStringRepresentation() -> String {
        return "v"
    }

    
}