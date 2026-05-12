
func getEqualContentTargetDTO(inputs: [String], target: String) throws -> EqualContentTargetDTO {
    var result: [String] = []
    for input in inputs {
        if (try isEquivalent(target, with: input)) {
            result.append(input)
        }
    }
    return EqualContentTargetDTO(target: target, equivalences: result)
}

func getEqualContentDTO(targets: [String]) throws -> EqualContentDTO {
    let results = try findEquivalenceRelations(for: targets)
    return EqualContentDTO(equivalences: results)
}