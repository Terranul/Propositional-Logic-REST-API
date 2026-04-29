// import Fluent
// import Vapor

// struct EvalController: RouteCollection {

//     func boot(routes: any Vapor.RoutesBuilder) throws {
//         let evals: any RoutesBuilder = routes.grouped("eval")
//     }

//     func getSingleEval(req: Request) throws -> EvalInputDTO {
//         let evalRequest: EvalRequest = try req.content.decode(EvalRequest.self)
//         let parser: StatementParser = StatementParser()
//         let value = req.parameters.get("statement")
//         guard let value else {
//             throw EvalCError.UndefinedParamater
//         }
//         let statement = try parser.parseStatement(value: value)

//     } 

    
// }