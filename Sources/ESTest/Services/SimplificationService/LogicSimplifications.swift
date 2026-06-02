/* 
A collection of functions for converting from the Quine–McCluskey BitField format back into the Statement api
The file is also responsible for applying extra simplifcations that fit the propositional logic language to shorten the statement further
*/

func convertToCNF(outcomes: [[Character: Bool]]) -> ComplexStatement {
    let (variables, results) = convertInputList(outcomes)
    let bitfields: Set<BitField> = getRawBitfields(results)
    return convertToCNF(outcomes: bitfields, variables: variables)
}

func convertToCNF(outcomes: Set<BitField>, variables: [Variable]) -> ComplexStatement {
    var outcomesConverted: [ComplexStatement] = []
    for outcome in outcomes {
        outcomesConverted.append(convertToStatement(outcome: outcome, variables: variables))
    }
    return ComplexStatement(components: outcomesConverted, op: OrOperator())
}

func convertToStatement(outcome: BitField, variables: [Variable]) -> ComplexStatement {
    let outcomeBits: Int32 = outcome.removeFlagBits()
    var rawStatements: [RawStatement] = []
    for i: Int in 0..<15 {
        if (i < variables.count) {
            let targetBit: Int32 = outcomeBits >> i
            if (targetBit == 1) {
                rawStatements.append(RawStatement(variable: variables[i], leadingOp: DefaultLeadingOperator()))
            } else {
                rawStatements.append(RawStatement(variable: variables[i], leadingOp: NotOperator()))
            }
        } 
    }
    return ComplexStatement(components: rawStatements, op: AndOperator())
 }