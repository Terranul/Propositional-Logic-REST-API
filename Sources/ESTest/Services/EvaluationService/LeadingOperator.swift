protocol LeadingOperator {

    func getStringRepresentation() -> String
    func applyOperation(value: Bool) -> Bool

}

class NotOperator: LeadingOperator {

    func getStringRepresentation() -> String {
        return "~"
    }

    func applyOperation(value: Bool) -> Bool {
        return !value
    }

}

class FalseSlashOperator: LeadingOperator {

    func getStringRepresentation() -> String {
        return "\\"
    }

    func applyOperation(value: Bool) -> Bool {
        return false
    }

}

class TrueSlashOperator: LeadingOperator {

    func getStringRepresentation() -> String {
        return "/"
    }

    func applyOperation(value: Bool) -> Bool {
        return true
    }

}

class DefaultLeadingOperator: LeadingOperator {

    func getStringRepresentation() -> String {
        return ""
    }

    func applyOperation(value: Bool) -> Bool {
        return value
    }
    
}