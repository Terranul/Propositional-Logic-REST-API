/* 
A collection of functions for converting from the Quine–McCluskey BitField format back into the Statement api
The file is also responsible for applying extra simplifcations that fit the propositional logic language to shorten the statement further
*/

func simplify(_ statement: any Statement) throws -> any Statement{
    let (variables, outcomes): ([Character], Set<BitField>) = try getEssentialImplicants(value: statement)
    return convertToCNF(outcomes: outcomes, variables: variables)
}

func convertToCNF(outcomes: [[Character: Bool]]) -> any Statement {
    let (variables, results) = convertInputList(outcomes)
    let bitfields: Set<BitField> = getRawBitfields(results)
    return convertToCNF(outcomes: bitfields, variables: variables)
}

func convertToCNF(outcomes: Set<BitField>, variables: [Variable]) -> any Statement {
    var outcomesConverted: [any Statement] = []
    for outcome in outcomes {
        outcomesConverted.append(convertToStatement(outcome: outcome, variables: variables))
    }
    print("convderting in convert to cnf")
    if (outcomesConverted.count == 1) {
        return outcomesConverted[0]
    } else {
        return ComplexStatement(components: outcomesConverted, op: OrOperator())
    }
}

func convertToStatement(outcome: BitField, variables: [Variable]) -> any Statement {
    let outcomeBits: Int32 = outcome.removeFlagBits()
    var rawStatements: [RawStatement] = []
    print("starting enumeration of convert to statement")
    for i: Int in 0..<15 {
        if (i < variables.count && !outcome.isFlagBit(index: i)) {
            let targetBit: Int32 = outcomeBits >> i
            if ((targetBit & 1) == 1) {
                rawStatements.append(RawStatement(variable: variables[variables.count - 1 - i], leadingOp: DefaultLeadingOperator()))
            } else {
                rawStatements.append(RawStatement(variable: variables[variables.count - 1 - i], leadingOp: NotOperator()))
            }
        } 
    }
    print("finished enumeratiokn of convert to statement")
    if (rawStatements.count == 1) {
        return rawStatements[0]
    } else {
         print("convderting in convert to statement")
        return ComplexStatement(components: rawStatements, op: AndOperator())
    }
 }

// post-order traversal of the logic tree that will try to apply logcial equivalences to simplify each sub-statement
 func localSimplify(on value: any Statement) {
    if let complxValue: ComplexStatement = value as? ComplexStatement {
        do {

        } catch {
            
        }
    } else {
        return
    }
 }