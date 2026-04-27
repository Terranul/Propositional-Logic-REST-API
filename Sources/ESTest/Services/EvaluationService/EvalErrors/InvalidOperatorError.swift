enum EvalError: Error {
    case InvalidOperator(operator: Character)
    case UndefinedVariable(variable: Character)
}
