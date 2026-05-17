import Vapor

enum EqualValidationError: Error {
    case ParsingError([any Error])
}


public struct EqualValidation: Middleware {

    public func respond(to request: Vapor.Request, chainingTo next: any Vapor.Responder)
        -> NIOCore.EventLoopFuture<Vapor.Response>
    {
        do {
            let evalRequest: EqualInputDTO = try request.content.decode(EqualInputDTO.self)
            if let failure: ParsingErrorsDTO = handleEqualErrors(
                request: request, statements: evalRequest.statements)
            {
                let encoded: Data  = try JSONEncoder().encode(failure)
                let response: Response = Response(
                    status: .badRequest,
                    headers: ["Content-Type": "application/json"],
                    body: .init(data: encoded))
                return request.eventLoop.makeSucceededFuture(response)
            }
            return next.respond(to: request)
        } catch {
            return request.eventLoop.makeFailedFuture(Abort(.internalServerError))
        }

    }

    private func handleEqualErrors(request: Vapor.Request, statements: [String]) -> ParsingErrorsDTO? {
        // the pre-screening will test the validity of the input statements
        let issues: [ParsingErrorsDTO.ParsingError] = statements.compactMap() { statement in
            let result: [any Error] = validateStatement(for: statement)
            guard result.count > 0 else {
                return nil
            }
            return ParsingErrorsDTO.ParsingError(issues: result, target: statement)
        }
        if(issues.isEmpty()) {
            return nil
        }
        return ParsingErrorsDTO(content: issues)
    }  
}

extension EvalDecoder {
    
    static func validations() {
        
    }
}