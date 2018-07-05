
import Vapor
import FluentPostgreSQL

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    var userID:User.ID //this is a reference to the user who posted the acronym, this is non optional. An acronym must have a user
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

extension Acronym: PostgreSQLModel {}

extension Acronym: Content {}

extension Acronym: Parameter {}

//get the acronym parents
extension Acronym {
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
}

//foreign key constraint set up
extension Acronym: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
    
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()
    }
}
