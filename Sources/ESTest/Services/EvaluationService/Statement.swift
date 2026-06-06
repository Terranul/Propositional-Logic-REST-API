// A placeholder to make a future transition to a dedicated Variable type easier
typealias Variable = Character

protocol Statement: AnyObject, Equatable {

    // master function to return the value of the propositional statement given the inputs
    // assume all related validity checks have occured and been addressed prior to running this
    // resolution map is a dictionary mapping each variable to its boolean value
    // can throw UndefinedVariable if a variable is not present in the resolution map
    func evaluate(resolutionMap: [Character: Bool]) throws -> Bool

    // the string representation of the modeled statement with spacing before and after each operator
    func getStatement() -> String

    // The Leading Reduced Form (LRF) which simplfies leading operators inwards
    // Features:
    // DeMorgan's is recursively applied inwards for negation (~) operators
    // Statements with False or True leading operators are simplified depending on the opertator (-a^b) -> -a
    // False and True simplfications lead to predictable but many quirks. Read the docs
    func toLRF() -> any Statement

    // The Conjunctive Normal Form (CNF) conversion
    func toCNF() -> any Statement

    func negate()

    // get a deep copy of the statement
    func copy() -> any Statement

    // replaces the current leading operator with the lop argument
    // ensure you have a single reference before calling this function
    func setLop(lop: any LeadingOperator) 

    static func == (lhs: Self, rhs: Self) -> Bool

    // a workaround to the fact == is janky with protocols
    func isEqual(to statement: any Statement) -> Bool

    // getters ________________________________________

    func getVariables() -> Set<Variable>


}