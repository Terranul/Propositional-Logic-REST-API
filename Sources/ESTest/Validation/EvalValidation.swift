import Vapor

// TODO: Make a parent enum that has a string param
enum ValidationError: Error {
    case UnbalancedParens(String)
    case MissingOuterParens(String)
    case MissingPathParamater(String)
    case MissingInputField(String) // in body

    var description: String  {
        switch (self) {
            case .UnbalancedParens(let message):
                return "Unbalanced parens; \(message)"
            default:
            //  TODO: CREATE EXHAUSTIVE CASES FOR ALL when you refactor the error handling later on
                return "internal error"
        }
    }
}

// surface level validation checks
public struct EvalValidation: Middleware {
    
    public func respond(to request: Vapor.Request, chainingTo next: any Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
        // apply initial acceptance checks
        if let issue: Abort = handleValidationErrors(request: request) {
            return request.eventLoop.makeFailedFuture(issue)
        }
        let result: EventLoopFuture<Response> = next.respond(to: request)
        // handle errors thrown from the eval service
        return result.flatMapError { error in
            return self.handleEvalError(error, on: request)
        }
    }

    private func handleEvalError(_ error: any Error, on request: Request) -> EventLoopFuture<Response> {
        let abort: Abort
        if let evalError = error as? EvalError {
            switch evalError {
            case .InternalParsingError:
                abort = Abort(.badRequest, reason: "The server encountered an error while attempting to parse your statement. Please review or contact support")
            case .InvalidOperator(let op):
                abort = Abort(.badRequest, reason: "operator: \(op) is undefined. Please refer to the documentation for valid operators")
            case .MalformedStatement:
                abort = Abort(.badRequest, reason: "Statement input is malformed, please verify correctness.")
            case .UndefinedVariable(let variable):
                abort = Abort(.badRequest, reason: "Variable: \(variable) was identified in your statement and is missing from your mapping key.")
            }
        } else {
            print("hit internal server errror here with error:" + String(describing: error))
            abort = Abort(.internalServerError)
        }
        return request.eventLoop.makeFailedFuture(abort)
    }

    public func handleValidationErrors(request: Vapor.Request) -> Abort? {
        do {
            try verifyParams(request: request)
            try checkParens(request.parameters.get("statement")!)
            //try verifyBody(request: request)
            return nil
        } catch ValidationError.UnbalancedParens(let msg),
                ValidationError.MissingOuterParens(let msg),
                ValidationError.MissingPathParamater(let msg),
                ValidationError.MissingInputField(let msg) {
            return Abort(.badRequest, reason: msg) 
        } catch {
            return Abort(.internalServerError, reason: "Internal issue while handling statement input")
        }
    }

 
    // IMPORTANT: ensure whitespace has been removed

    func checkParens(_ statement: String) throws {
        let result = Array(statement).reduce(0) { (cur: Int, char: Character) in
            if (char == "(") {
                return cur + 1
            } else if (char == ")") {
                return cur - 1
            } else {
                return cur
            }
        }
        if (result > 0) {
            throw ValidationError.UnbalancedParens("Unbalanced Parenthesis. Too many right parens.")
        } else if (result < 0) {
            throw ValidationError.UnbalancedParens("Unbalanced Parenthesis. Too many left parens.")
        }
        // if ((Array(statement)[0] != "(" && Array(statement)[statement.count - 1] != ")") && Array(statement).count > 2) {
        //     throw ValidationError.MissingOuterParens("Missing outer pair of parens.")
        // }
    }

    func verifyParams(request: Request) throws {
        guard request.parameters.get("statement") != nil else {
            throw ValidationError.MissingPathParamater("missing statement path paramater: /eval/{statement}")
        }
    }

    // TODO
    func verifyBody(request: Request) throws {
        let evalRequest: EvalDecoder = try request.content.decode(EvalDecoder.self)

    }
}

extension ValidatorResults {

    public struct Statement: ValidatorResult {

        public var errors: [any Error]

        public var isFailure: Bool

        public var successDescription: String? = "Syntactically valid statement"

        public var failureDescription: String? {
            for error in errors {
                return "a"
            }
            return "h"
        }


    }
}

