// import Vapor

// enum EqualValidationError: Error {
//     case ParsingError([any Error])
// }


// public struct EqualValidation: Middleware {

//     public func respond(to request: Vapor.Request, chainingTo next: any Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
//         let result: EventLoopFuture<Response> = next.respond(to: request)
//         result.flatMapError() { error in

//         }
//     }

//     public func handleEqualErrors(error: any Error, request: Request) -> EventLoopFuture<Response>{
//         // the pre-screening will test the validity of the input statements

//     }



    
// }