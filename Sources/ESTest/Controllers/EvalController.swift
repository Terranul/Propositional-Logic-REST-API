import Fluent
import Vapor

struct EvalController: RouteCollection {

    let evalBridge: EvalBridge = EvalBridge()

    func boot(routes: any Vapor.RoutesBuilder) throws {
        let evals: any RoutesBuilder = routes.grouped("eval")
        evals.get(":statement", use: getAllEval)
    }

    func getSingleEval(req: Request) throws -> EvalTotalDTO {
        let evalRequest: EvalDecoder = try req.content.decode(EvalDecoder.self)
        guard let script: String = req.parameters.get("statement") else {
            throw EvalCError.UndefinedParamater
        }
        // most surface level validation will throw from here
        let statement: any Statement = try evalBridge.getStatement(script)
        let result: EvalContent = evalBridge.getContentDTO(statement: statement, inputs: evalRequest.inputs)
        return EvalTotalDTO(statement: script,
                            statementPretty: evalBridge.getPrettyStatement(statement: statement), 
                            results: [result])
    }  


    func getAllEval(req: Request) throws -> EvalTotalDTO {
        print("entered")
        guard let script: String = req.parameters.get("statement") else {
            throw EvalCError.UndefinedParamater
        }
        let statement: any Statement = try evalBridge.getStatement(script)
        let results: [EvalContent] = evalBridge.getAllDTO(statement: statement, inputs: try evalBridge.getAllResults(value: script))
        return EvalTotalDTO(statement: script,
                            statementPretty: evalBridge.getPrettyStatement(statement: statement), 
                            results: results)
    }
}