struct EvalBridge {

    func getContentDTO(statement: any Statement, inputs: [Character: Bool]) throws -> EvalContent{
        let result: Bool = try statement.evaluate(resolutionMap: inputs)
        return EvalContent(inputs: inputs, result: result)
    }

    func getAllDTO(statement: any Statement, inputs: [[Character: Bool]]) throws -> [EvalContent] {
        return try inputs.map({ value  in 
            return try getContentDTO(statement: statement, inputs: value)
        })
    }

    func getStatement(_ script: String) throws -> any Statement {
        let compactScript: String = script.replacing(" ", with: "")
        return try groupedParser().parseStatement(value: compactScript)
    }

    func getPrettyStatement(statement: any Statement) -> String{
        return statement.getStatement()
    }

    func getAllResults(value: String) throws -> [[Character : Bool]] {
        let variables: [Character] = identfiyVariables(value: value)
        let permutations = 1 << variables.count
        var inputs = initializeVariables(variables: variables)
        var inputsList: [[Character : Bool]] = []
        for i: Int in 0..<permutations {
            for h: Int in 0..<variables.count {
                let keyValue = 1 << (variables.count - h - 1)
                // we know to flip the bool when i is a multiple of keyvalue
                if ((i) % (keyValue) == 0) {
                    let curValue: Bool? = inputs[variables[h]]
                    inputs[variables[h]] = !(curValue!)
                }
            }
            // add the new inputs permutations to the list
            print("adding" + inputsList.debugDescription)
            inputsList.append(inputs)
        }
        return inputsList
    }

    // return a list of all characters not operators or parens
    // REQUIRES all spaces have been removed from value
    // TODO: Future update should adopt : format before variables to be more explicit
    func identfiyVariables(value: String) -> [Character] {
        var varList: Set<Character> = []
        let operatorParser: OperatorParser = OperatorParser()
        for char: Character in value {
            if (operatorParser.isOperator(value: char) || char == "(" || char == ")" || operatorParser.isLeadingOperator(value: char)) {
                continue;
            }
            varList.insert(char)
        }
        // will not return variables in left to right order, but this is not important
        return Array(varList)
    }

    // turns each character into a mapping to the value true
    func initializeVariables(variables: [Character]) -> [Character: Bool] {
        var dict: [Character: Bool] = [:]
        for v in variables {
            dict[v] = false
        }
        return dict
    }
}