import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Welcome to everything propositional logic"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    let v100: any RoutesBuilder = app.grouped("v1.0.0")
    try v100.register(collection: EvalController())

}
