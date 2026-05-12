
func findEquivalenceRelations(for statements: [String]) throws -> Dictionary<String, Set<String>> {
    var equivalenceDict: Dictionary<String, Set<String>> = [:]
    for statementTarget in statements {
        if (equivalenceDict[statementTarget] == nil) {
            equivalenceDict[statementTarget] = Set<String>()
        }
        for statement in statements {
            if (statementTarget == statement) {continue}
            if (equivalenceDict[statementTarget]!.contains(statement)) {continue}
            if (try isEquivalent(statementTarget, with: statement)) {
                if let statementEquivalence: Set<String> = equivalenceDict[statement] {
                    equivalenceDict[statementTarget]!.formUnion(statementEquivalence)
                } else {
                    equivalenceDict[statement] = Set<String>()
                }
                equivalenceDict[statement]!.insert(statementTarget)
                equivalenceDict[statementTarget]!.insert(statement)
            }
        }
    }
    return equivalenceDict
}

func isEquivalent(_ a: String, with b: String) throws -> Bool {
    if (!applyVariableScreening(a, b)) {return false}
    let statementParser = StatementParser()
    // we'll need to dip into the eval bridge a bit, but that's what it is for
    let allInputs: [[Character : Bool]] = try EvalBridge().getAllResults(value: a) // OOP issues
    let statementA: any Statement = try statementParser.parseStatement(value: a)
    let statementB: any Statement = try statementParser.parseStatement(value: b)
    for input: [Character : Bool] in allInputs {
        let equivalence = try isInputEquivalent(statementA, with: statementB, for: input)
        if (!equivalence) {
            return false
        }
    }
    return true
}

func isEquivalent(_ a: any Statement, with b: any Statement, allInputs: [[Character : Bool]]) throws -> Bool {
    for input: [Character : Bool] in allInputs {
        let equivalence: Bool = try isInputEquivalent(a, with: b, for: input)
        if (!equivalence) {
            return false
        }
    }
    return true
}

fileprivate func isInputEquivalent(_ a: any Statement, with b: any Statement, for input: [Character: Bool]) throws -> Bool{
    let resultA = try a.evaluate(resolutionMap: input)
    let resultB = try b.evaluate(resolutionMap: input)
    return resultA == resultB
}

fileprivate func applyVariableScreening(_ a: String, _ b: String) -> Bool {
    let aVaraibles: [Character] = EvalBridge().identfiyVariables(value: a)
    let bVariable: [Character] = EvalBridge().identfiyVariables(value: b)
    if (aVaraibles.count != bVariable.count) {return false}
    let bSet: Set<Character> = Set(bVariable)
    // we don't need to check both ways becuase the count check takes care of it
    for variable in aVaraibles {
        if (!bSet.contains(variable)) {
            return false
        }
    }
    return true
}
