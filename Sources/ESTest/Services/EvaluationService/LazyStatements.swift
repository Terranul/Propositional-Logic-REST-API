/*

A near identical implementation of complex/raw statments except these do not perform the outcome matching logic to generate a 
specific bitfield sequence. 

A version of evaluate that does not use bitfield sequences is still provided, but it is recommended to only use this variant
when requiring statement manipulation or heavy inits

*/

// TODO: conform this to the complex statement protocol with existentials

import OrderedCollections

class LazyEvalComplexStatement: ComplexStatement {

   override init(lhs: any Statement, rhs: any Statement, op: any Operator, leadingOp: any LeadingOperator) {
        super.init(lhs: lhs, rhs: rhs, op: op, leadingOp: leadingOp, outcomeMatch: BitFieldSequence(value: BitFieldSequence.getAlwaysTrueBitField()))
   }

   override init(components: [any Statement], op: any Operator) {
        super.init(components: components, op: op, outcomeMatch: BitFieldSequence(value: BitFieldSequence.getAlwaysTrueBitField()))
   }

   override func evaluate(resolutionMap: [Character : Bool]) throws -> Bool {
        let lhsResult = try lhs.evaluate(resolutionMap: resolutionMap)
        let rhsResult: Bool = try rhs.evaluate(resolutionMap: resolutionMap)
        let result: Bool = op.applyOperation(lhs: lhsResult, rhs: rhsResult)
        return leadingOp.applyOperation(value: result)
   }

   override func isSolved() -> Bool {
        // todo
        return true
   }

   override func negate() {
        self.leadingOp = leadingOp.negate()
    }


    // converts statement back to ComplexStatement
    func reInit() -> ComplexStatement {
        return ComplexStatement(lhs: super.lhs, rhs: self.rhs, op: self.op, leadingOp: self.leadingOp)
    }
}