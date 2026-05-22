// TODO: Leading Operators and Operators should become swift enums since indentification checks are so important

protocol LeadingOperator {

    func getStringRepresentation() -> String
    func applyOperation(value: Bool) -> Bool
    func getLength() -> Int
    func negate() -> any LeadingOperator

}

extension LeadingOperator {

    func getLength() -> Int {
        return 1
    }
}

class NotOperator: LeadingOperator {

    func getStringRepresentation() -> String {
        return "~"
    }

    func applyOperation(value: Bool) -> Bool {
        return !value
    }

    func negate() -> any LeadingOperator {
        return DefaultLeadingOperator()
    }

}

class FalseSlashOperator: LeadingOperator {

    func getStringRepresentation() -> String {
        return "-"
    }

    func applyOperation(value: Bool) -> Bool {
        return false
    }

    func negate() -> any LeadingOperator {
        return TrueSlashOperator()
    }

}

class TrueSlashOperator: LeadingOperator {

    func getStringRepresentation() -> String {
        return "+"
    }

    func applyOperation(value: Bool) -> Bool {
        return true
    }

    func negate() -> any LeadingOperator {
        return FalseSlashOperator()
    }

}

class DefaultLeadingOperator: LeadingOperator {

    func getStringRepresentation() -> String {
        return ""
    }

    func applyOperation(value: Bool) -> Bool {
        return value
    }

    func negate() -> any LeadingOperator {
        return NotOperator()
    }

    func getLength() -> Int {
        return 0
    }
}


// a high-level representation of consecutive leading operators: ex. +~-(a^b) and ~~a
class ComplexLeadingOperator: LeadingOperator {
    var guts: [any LeadingOperator]

    init(guts: [any LeadingOperator]) {
        self.guts = guts
    }

    func applyOperation(value: Bool) -> Bool {
        var valueResult = value
        // go right to left applying leading operators
        for i in (0..<self.guts.count).reversed() {
            let lop: any LeadingOperator = self.guts[i]
            valueResult = lop.applyOperation(value: valueResult)
        }
        return valueResult
    }

    func getStringRepresentation() -> String {
        return self.guts.reduce("") { acc, lop in
            return acc + lop.getStringRepresentation()
        }
    }

    func negate() -> any LeadingOperator {
        return ComplexLeadingOperator(guts: self.guts + [NotOperator()])
    }

    func getLength() -> Int {
        return self.guts.count
    }
}