struct EvalBridge {

    func getResult(inputs: [String: Bool], value: String) throws -> EvalInputDTO { 
        let parser: StatementParser = StatementParser() 
        let statement = try parser.parseStatement(value: value)
        let convertedDict: [Character : Bool] = try convertDictionary(dict: inputs)
        let result: Bool = statement.evaluate(resolutionMap: convertedDict)
        return EvalInputDTO(statement: value, 
                            statementPretty: statement.getStatement(), 
                            inputs: inputs, 
                            result: result)
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

    func getTotalDTO(value: String) throws -> EvalTotalDTO {
        let variableInputs: [[Character : Bool]] = try getAllResults(value: value)
        var resultsList: [EvalDTO] = []
        let parser = StatementParser()
        let statement: any Statement = try parser.parseStatement(value: value)
        for input: [Character : Bool] in variableInputs {
            let result = statement.evaluate(resolutionMap: input)
            let eval = EvalDTO(inputs: input, result: result)

        }
    }

    func convertDictionary(dict: [String: Bool]) throws -> [Character: Bool] {
        let modifiedMap: [(Character, Bool)] = try dict.compactMap{ key, value -> (Character, Bool) in
            guard key.count == 1 else {
                throw EvalCError.UndefinedParamater
            }
            return (Character(key), value)
        }
        // convert back to a dictionary
        return Dictionary(modifiedMap, uniquingKeysWith: { (value1, value2) in 
            return value1
        })
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