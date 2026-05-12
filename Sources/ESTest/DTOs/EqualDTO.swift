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