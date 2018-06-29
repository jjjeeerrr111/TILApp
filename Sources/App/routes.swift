import Vapor
import Fluent
/// Register your application's routes here.
public func routes(_ router: Router) throws {

    
    //save a newly created acronym
    router.post("api","acronyms") { req -> Future<Acronym> in
        return try req.content.decode(Acronym.self)
            .flatMap(to: Acronym.self) { acronym in
                return acronym.save(on: req)
        }
    }
    
    //fetch acronyms
    router.get("api","acronyms") { req -> Future<[Acronym]> in
        return Acronym.query(on: req).all()
    }
    
    //fetch acronym by ID
    router.get("api","acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    //update an existing Acronym by ID
    router.put("api","acronyms",Acronym.parameter) { req -> Future<Acronym> in
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, updatedAcronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            
            return acronym.save(on: req)
        }
    }
    
    //delete an existing acronym by ID
    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
        .delete(on: req)
        .transform(to: HTTPStatus.noContent)
    }
    
    //search for an acronym
    router.get("api","acronyms","search") { req -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }.all()
    }
    
    //return first acronym
    router.get("api","acronyms","first") { req -> Future<Acronym> in
        return Acronym.query(on: req).first().map(to: Acronym.self) { acronym in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            
            return acronym
        }
    }
    
    //sort acronyms in ascending order
    router.get("api","acronyms","sorted") { req -> Future<[Acronym]> in
        return Acronym.query(on: req).sort(\.short, .ascending).all()
    }
}
