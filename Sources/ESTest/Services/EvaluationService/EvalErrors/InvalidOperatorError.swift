enum EvalError: Error {
    case InvalidOperator(operator: Character)
    case UndefinedVariable(variable: Character)
    case MalformedStatement(message: String)
    case InternalParsingError

    var description: String {
        switch self {
            case .InvalidOperator(let op):
                return "Operator: \(op) is invalid"
            case .MalformedStatement:
                return "Statement is malformed"
            case .UndefinedVariable(let variable):
                return "Variable \(variable) has not been mapped to a specific truth value"
            case .InternalParsingError:
                return "Internal parsing issue."
        }
    }
}
