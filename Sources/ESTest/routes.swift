import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Welcome to everything propositional logic"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: EvalController())
}
