// TODO: Leading Operators and Operators should become swift enums since indentification checks are so important

protocol LeadingOperator {

    func getStringRepresentation() -> String
    func applyOperation(value: Bool) -> Bool
    func getLength() -> Int
    func negate() -> any LeadingOperator

    // move the leading operator inwards one level
    func pushInward(lhs: inout any Statement, rhs: inout any Statement, op: any Operator) -> any Statement

    // applies the lop argument to the left of self and resolves the disupute
    // ex. NotOperator.apply(to: TrueSlashOperator()) -> FalseSlashOperator()
    func apply(to lop: any LeadingOperator) -> any LeadingOperator

}

extension LeadingOperator {

    func getLength() -> Int {
        return 1
    }
}

class NotOperator: LeadingOperator {

    func apply(to lop: any LeadingOperator) -> any LeadingOperator {
        return lop.negate()
    }


    func pushInward(lhs: inout any Statement, rhs: inout any Statement, op: any Operator) -> any Statement {
       return op.negateOperator(lhs: lhs, rhs: rhs)
    }


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

// ( (a ^ b) v  -((c ^ a) ^ c))



class FalseSlashOperator: LeadingOperator {

    func apply(to lop: any LeadingOperator) -> any LeadingOperator {
        return FalseSlashOperator()
    }

    // rules for says that you will always turn -(lhs op rhs) into -lhs
    func pushInward(lhs: inout any Statement, rhs: inout any Statement, op: any Operator) -> any Statement {
        return withUniqueReference(value: &lhs) { statement in
            statement.setLop(lop: FalseSlashOperator())
            return statement
        }
    }


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

    func apply(to lop: any LeadingOperator) -> any LeadingOperator {
        return TrueSlashOperator()
    }


    func pushInward(lhs: inout any Statement, rhs: inout any Statement, op: any Operator) -> any Statement {
        return withUniqueReference(value: &lhs) { statement in
            statement.setLop(lop: TrueSlashOperator())
            return statement
        }
    }


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

    func apply(to lop: any LeadingOperator) -> any LeadingOperator {
        return lop
    }

    func pushInward(lhs: inout any Statement, rhs: inout any Statement, op: any Operator) -> any Statement {
        return ComplexStatement(lhs: lhs, rhs: rhs, op: op, leadingOp: DefaultLeadingOperator())
    }


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

    func apply(to lop: any LeadingOperator) -> any LeadingOperator {
        var newGuts = guts
        newGuts.insert(lop, at: 0)
        return ComplexLeadingOperator(guts: newGuts)
    }

    // resolves the guts first then applies inward operations
    func pushInward(lhs: inout any Statement, rhs: inout any Statement, op: any Operator) -> any Statement {
        let lop: any LeadingOperator = self.resolve()
        // we know for sure we will not get another ComplexLeadingOperator as the lop
        return lop.pushInward(lhs: &lhs, rhs: &rhs, op: op)
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

    // returns the single simplfied version of the guts
    func resolve() -> any LeadingOperator {
        // the current resolution of the guts
        var cur: any LeadingOperator = DefaultLeadingOperator()
        for lop: any LeadingOperator in guts.reversed() {
            cur = lop.apply(to: cur)
        }
        return cur
    }
}