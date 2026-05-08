import Fluent
import Vapor

struct EvalController: RouteCollection {

    // middleware handles every possible error...

    let evalBridge: EvalBridge = EvalBridge()

    func boot(routes: any Vapor.RoutesBuilder) throws {
        let evals: any RoutesBuilder = routes.grouped("eval").grouped(EvalValidation())
        evals.get(":statement", use: getAllEval)
        evals.post(":statement", use: getSingleEval)
    }

    func getSingleEval(req: Request) throws -> EvalTotalDTO {
        let evalRequest: EvalDecoder = try req.content.decode(EvalDecoder.self)
        let script: String = req.parameters.get("statement")!
        // most surface level validation will throw from here
        let statement: any Statement = try evalBridge.getStatement(script)
        let result: EvalContent = try evalBridge.getContentDTO(statement: statement, inputs: evalRequest.inputs)
        return EvalTotalDTO(statement: script,
                            statementPretty: evalBridge.getPrettyStatement(statement: statement), 
                            results: [result])
    }  


    func getAllEval(req: Request) throws -> EvalTotalDTO {
        print("entered")
        let script: String = req.parameters.get("statement")!
        let statement: any Statement = try evalBridge.getStatement(script)
        let results: [EvalContent] = try evalBridge.getAllDTO(statement: statement, inputs: try evalBridge.getAllResults(value: script))
        return EvalTotalDTO(statement: script,
                            statementPretty: evalBridge.getPrettyStatement(statement: statement), 
                            results: results)
    }
}