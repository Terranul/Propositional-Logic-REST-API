import Testing
@testable import ESTest

@Test func testConvertDictionary() async throws {
    let evalBridge: EvalBridge = EvalBridge()
    let dict: [String: Bool] = ["a": true, "b": false, "c": true]
    do {
        let result: [Character : Bool] = try evalBridge.convertDictionary(dict: dict)
        #expect(result["a"]! && !result["b"]! && result["c"]!)
    } catch {
        #expect(Bool(false))
    }

}

@Test func getAllResultsTest() async throws {
    let evalBridge: EvalBridge = EvalBridge()
    do {
        var result: [[Character : Bool]] = try evalBridge.getAllResults(value: "a")
        #expect(result == [["a": true], ["a": false]])
        result = try evalBridge.getAllResults(value: "a^b")
        #expect(result == [["a": true, "b": true], ["a": true, "b": false], ["a": false, "b": true], ["a": false, "b": false]])
        result = try evalBridge.getAllResults(value: "((a^b)^c)")
        #expect(result.count == 8)
        #expect(result.contains(["a": true, "b": true, "c": true]))
        #expect(result.contains(["a": false, "b": true, "c": false]))
        result = try evalBridge.getAllResults(value: "((a^b)^(c^d)")
        #expect(result.count == 16)
    } catch {
        #expect(Bool(false))
    }
}

@Test func identifyVariables() async throws {
    let evalBridge: EvalBridge = EvalBridge()
    var result = evalBridge.identfiyVariables(value: "((a^b)vc)")
    #expect(result.contains("a") && result.contains("c") && result.contains("b"))
    result = evalBridge.identfiyVariables(value: "(a^a)")
    #expect(result.contains("a") && result.count == 1)
}

@Test func testInitInputs() async throws {
    let evalBridge: EvalBridge = EvalBridge()
    let result = evalBridge.initializeVariables(variables: ["a", "b", "c"])
    #expect(result == ["a": true, "b": true, "c": true])
}