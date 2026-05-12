import Vapor

struct EqualController: RouteCollection {

    func boot(routes: any Vapor.RoutesBuilder) throws {
        let evals: any RoutesBuilder = routes.grouped("equal")
        evals.post(":target", use: getEqivalencesTarget)
        evals.post("", use: getEqivalences)

    }

    func getEqivalencesTarget(req: Request) throws -> EqualContentTargetDTO {
        let input: EqualInputDTO = try req.content.decode(EqualInputDTO.self)
        let target: String = req.parameters.get("target")!
        return try getEqualContentTargetDTO(inputs: input.statements, target: target)
    }

    func getEqivalences(req: Request) throws -> EqualContentDTO{
        let input: EqualInputDTO = try req.content.decode(EqualInputDTO.self)
        return try getEqualContentDTO(targets: input.statements)
    }

}