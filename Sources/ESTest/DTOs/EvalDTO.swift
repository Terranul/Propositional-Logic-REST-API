import Fluent
import Vapor

struct EvalInputDTO: Content {
    let statement: String
    let statementPretty: String
    let inputs: [String: Bool]
    let result: Bool
}

struct EvalTotalDTO: Content {
    let statement: String
    let statementPretty: String
    let results: [EvalContent]
}

// request content DTO's 

struct EvalRequest: Content {
    let inputs: [String: Bool]
}

// to manually decode and encode [Character: Bool] type into [String: Bool] mapping for JSON

struct EvalContent: Content {

    enum CodingKeys: CodingKey {
        case inputs, result
    }

   var inputs: [Character: Bool]
   let result: Bool

   init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<EvalContent.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let initValue: [String : Bool] = try container.decode(Dictionary<String, Bool>.self, forKey: .inputs)
        self.inputs = [:]
        result = try container.decode(Bool.self, forKey: .result)
        inputs = try convertDictionary(dict: initValue)
   }

   init(inputs: [Character: Bool], result: Bool) {
        self.inputs = inputs
        self.result = result
   }        

    func encode(to encoder: any Encoder) throws {
        let stringDict: [String : Bool] = Dictionary(
            uniqueKeysWithValues: inputs.map { key, value in
                (String(key), value)
            }
        )
        var container: KeyedEncodingContainer<EvalContent.CodingKeys> = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stringDict, forKey: .inputs)
        try container.encode(result, forKey: .result)
    }

    private func convertDictionary(dict: [String: Bool]) throws -> [Character: Bool] {
        let modifiedMap: [(Character, Bool)] = try dict.compactMap{ key, value -> (Character, Bool) in
            guard key.count == 1 else {
                throw EvalError.InternalParsingError
            }
            return (Character(key), value)
        }
        // convert back to a dictionary
        return Dictionary(modifiedMap, uniquingKeysWith: { (value1, value2) in 
            return value1
        })
    }
}

struct EvalDecoder: Decodable {
    
    enum CodingKeys: CodingKey {
        case inputs
    }

    var inputs: [Character: Bool]

    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<EvalDecoder.CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let initValue: [String : Bool] = try container.decode(Dictionary<String, Bool>.self, forKey: .inputs)
        self.inputs = [:] // if the conversion fails, error will bubble up and we'll never have to deal with this case
        inputs = try convertDictionary(dict: initValue)
    }

    private func convertDictionary(dict: [String: Bool]) throws -> [Character: Bool] {
        let modifiedMap: [(Character, Bool)] = try dict.compactMap{ key, value -> (Character, Bool) in
            guard key.count == 1 else {
                throw ValidationError.MissingInputField("Missing input field in request body")
            }
            return (Character(key), value)
        }
        // convert back to a dictionary
        return Dictionary(modifiedMap, uniquingKeysWith: { (value1, value2) in 
            return value1
        })
    }
}