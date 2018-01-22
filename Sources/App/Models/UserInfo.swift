//
//  UserInfo.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/19/18.
//

import Foundation
import Vapor
import FluentProvider
//import AuthProvider

final class UserInfo: Model, Timestampable, Storable {

    enum LoginType: Int {
        case userpassword = 0
        case google
    }
 
    enum Status: Int {
        case active = 0
        case inactive
    }

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let email = "email"
        static let loginType = "loginType"
        static let status = "status"
        static let projectIDs = "projectIDs"
    }

    let storage = Storage()
    var name: String
    var email: String
    var loginType: LoginType
    var status: Status

    var projects: Children<UserInfo, ProjectInfo> {
        return children()
    }

    init(name: String, email: String, loginType: LoginType) {
        self.name = name
        self.email = email
        self.loginType = loginType
        self.status = .active
    }

    init(row: Row) throws {
        name = try row.get("name")
        email = try row.get("email")
        loginType = LoginType(rawValue: try row.get("loginType")) ?? .userpassword
        status = .active
    }

    func makeRow() throws -> Row {
        var row = Row()

        try row.set("name", name)
        try row.set("id", id)
        try row.set("email", email)
        try row.set("status", status.rawValue)
        try row.set("loginType", loginType.rawValue)
//        try row.set("projectIDs", projects.all().map {$0.idKey} )

        return row
    }
}

// MARK: Preparation
extension UserInfo: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { user in
            user.id()
            user.string("name")
            user.string("email")
            user.int("status")
            user.int("loginType")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension UserInfo: ResponseRepresentable { }

// MARK: JSONConvertible
extension UserInfo: JSONConvertible {
    convenience init(json: JSON) throws {
        guard let email         = json[Keys.email]?.string,
            let name            = json[Keys.name]?.string,
            let loginTypeInt    = json[Keys.loginType]?.int,
            let loginType       = LoginType(rawValue: loginTypeInt)
        else {
                throw Abort.badRequest
        }

        self.init(name: name, email: email, loginType: loginType)
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id?.string)
        try json.set("name", name)
        try json.set("email", email)
        try json.set("status", status.rawValue)
        try json.set("projectIDs", try projects.all().map {$0.idKey} )
        return json
    }
}

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension UserInfo: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<UserInfo>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Keys.name, String.self) { user, name in
                user.name = name
            }
        ]
    }
}
