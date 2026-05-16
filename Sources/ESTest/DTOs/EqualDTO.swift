import Vapor

struct EqualInputDTO: Decodable {
    let statements: [String]
}

// output when a target is specified in the path
struct EqualContentTargetDTO: Content {
    let target: String
    let equivalences: [String]
}

// output when no target is specified in the path
struct EqualContentDTO: Content {
    let equivalences: Dictionary<String, Set<String>>
}

// DTO's for error responses
struct ParsingErrorsDTO: Content {
    let message: String
    let content: [ParsingError]

    struct ParsingError: Content {
        let target: String // the reference statement
        var issues: [String]

        init(issues: [any Error], target: String) {
            self.target = target
            self.issues = []
            for issue in issues {
                if let issue: EvalError = issue as? EvalError {
                    self.issues.append(issue.description)
                }
                if let issue: ValidationError = issue as? ValidationError {
                    self.issues.append(issue.description)
                }
            }
        }
    }

    init(content: [ParsingError]) {
        self.content = content
        self.message = "The following issues have been detected in your response"
    }
}

