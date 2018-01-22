//
//  SimpleToken.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/22/18.
//

import Foundation
import Vapor
import FluentProvider

final class SimpleToken: Model, Timestampable {

    let storage: Storage = Storage()
    let string: String
    let userId: Identifier?

    var user: Parent<SimpleToken, UserInfo> {
        return parent(id: userId)
    }

    init(user: UserInfo) {
        userId = user.id
        string = "Sea\(user.id?.int ?? 0)"
    }

    init(row: Row) throws {
        string       = try row.get("string")
        userId      = try row.get("userId")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("string", string)
        try row.set("userId", userId)
        return row
    }

}

extension SimpleToken: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { token in
            token.id()
            token.string("string")
//            token.parent(UserInfo.self)
            token.foreignId(for: UserInfo.self, optional: false, unique: false, foreignIdKey: "userId", foreignKeyName: "FK_UserInfo_SimpleToken")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
