//
//  AppInfo.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/19/18.
//

import Foundation
import Vapor
import FluentProvider

final class AppInfo: Model, Timestampable {

    struct Keys {
        static let id = "id"
        static let projectID = "projectID"
        static let ownerID = "ownerID"
        static let name = "name"
        static let desc = "description"
        static let logIds = "logIds"
        static let createdDate = UserInfo.createdAtKey
        static let updatedDate = UserInfo.updatedAtKey
    }

    let storage = Storage()
    let projectID: Identifier
    let ownerId: Identifier

    var name: String
    var desc: String

//    var logs: Children<AppInfo, LogInfo> {
//        return children()
//    }

    var project: Parent<AppInfo, ProjectInfo> {
        return parent(id: projectID)
    }

    var owner: Parent<AppInfo, UserInfo> {
        return parent(id: ownerId)
    }

    init(row: Row) throws {
        name        = try row.get("name")
        projectID   = try row.get("projectID")
        ownerId     = try row.get("ownerID")
        desc        = try row.get("desc")
    }

    init(project: ProjectInfo, owner: UserInfo, name: String) {
        self.name = name
        self.ownerId = owner.id!
        self.projectID = project.id!
        self.desc = ""
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.desc, desc)
        try row.set(Keys.ownerID, ownerId)
        try row.set(Keys.projectID, projectID)
        return row
    }
}

extension AppInfo: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (builder) in
            builder.string(Keys.name)
            builder.string(Keys.desc)
            builder.parent(UserInfo.self, optional: false, unique: false, foreignIdKey: Keys.ownerID)
            builder.parent(UserInfo.self, optional: false, unique: false, foreignIdKey: Keys.projectID)
        })
    }


    static func revert(_ database: Database) throws {
        try database.delete(self)
    }

}

extension AppInfo: JSONConvertible {

    convenience init(json: JSON) throws {
        guard let owner: UserInfo = try json.get(Keys.ownerID),
            let project: ProjectInfo = try json.get(Keys.projectID),
            let name = json[Keys.name]?.string else {
                throw Abort.badRequest
        }

        self.init(project: project, owner: owner, name: name)
        self.desc = json[Keys.desc]?.string ?? ""
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.name, name)
        try json.set(Keys.desc, desc)
        try json.set(Keys.ownerID, ownerId.int)
        try json.set(Keys.projectID, projectID.int)
        try json.set(Keys.createdDate, createdAt)
        try json.set(Keys.updatedDate, updatedAt)
        return json
    }

}

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension AppInfo: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<AppInfo>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Keys.name, String.self) { user, name in
                user.name = name
            },

            UpdateableKey(Keys.desc, String.self) { user, desc in
                user.desc = desc
            },
        ]
    }
}

extension AppInfo: ResponseRepresentable { }

