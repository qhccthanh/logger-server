//
//  Project.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/19/18.
//

import Foundation
import Vapor
import FluentProvider

final class ProjectInfo: Model, Timestampable {

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let ownerId = "ownerId"
        static let memberIds = "memberIds"
        static let appIds = "appIds"
        static let createdDate = UserInfo.createdAtKey
        static let updatedDate = UserInfo.updatedAtKey
    }

    let storage = Storage()
    var name: String
    let ownerId: Identifier

//    var members: Siblings<ProjectInfo, UserInfo, Pivot<ProjectInfo, UserInfo>> {
//        return siblings()
//    }
//
//    var apps: Children<ProjectInfo,AppInfo> {
//        return children()
//    }

    var owner: Parent<ProjectInfo, UserInfo> {
        return parent(id: ownerId)
    }

    init(row: Row) throws {
        name = try row.get(Keys.name)
        ownerId = try row.get(Keys.ownerId)
    }

    init(owner: UserInfo, name: String) {
        self.ownerId = owner.id!
        self.name = name
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.ownerId, ownerId)
//        try row.set("memberIDs", try members.all().map {$0.idKey} )
//        try row.set("appIDs", try apps.all().map {$0.idKey})
        return row
    }
}

extension ProjectInfo: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { project in
            project.id()
            project.string(Keys.name)
            project.parent(UserInfo.self, optional: false, unique: false, foreignIdKey: Keys.ownerId)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension ProjectInfo: JSONConvertible {

    convenience init(json: JSON) throws {
        guard let ownerID = json[Keys.ownerId]?.string,
                let owner = try UserInfo.find(ownerID),
                let name = json[Keys.name]?.string else {
            throw Abort.badRequest
        }

        self.init(owner: owner, name: name)
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id?.string)
        try json.set(Keys.name, name)
        try json.set(Keys.ownerId, ownerId.int)
//        try json.set(Keys.memberIds, try members.all().map {$0.idKey} )
//        try json.set(Keys.appIds, try apps.all().map {$0.idKey})
        try json.set(Keys.createdDate, createdAt)
        try json.set(Keys.updatedDate, updatedAt)
        return json
    }

}

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension ProjectInfo: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<ProjectInfo>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Keys.name, String.self) { user, name in
                user.name = name
            }
        ]
    }
}

extension ProjectInfo: ResponseRepresentable { }
