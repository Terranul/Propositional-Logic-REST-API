protocol Statement {

    // master function to return the value of the propositional statement given the inputs
    // assume all related validity checks have occured and been addressed prior to running this
    // resolution map is a dictionary mapping each variable to its boolean value
    // can throw UndefinedVariable if a variable is not present in the resolution map
    func evaluate(resolutionMap: [Character: Bool]) throws -> Bool

    // the string representation of the modeled statement with spacing before and after each operator
    func getStatement() -> String
}