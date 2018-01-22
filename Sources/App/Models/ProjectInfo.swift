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
    let ownerId: Identifier?

    var members: Siblings<ProjectInfo, UserInfo, Pivot<ProjectInfo, UserInfo>> {
        return siblings()
    }

    var apps: Children<ProjectInfo,AppInfo> {
        return children()
    }

    var owner: Parent<ProjectInfo, UserInfo> {
        return parent(id: ownerId)
    }

    init(row: Row) throws {
        name = try row.get("name")
        ownerId = try row.get(UserInfo.foreignIdKey)
    }

    init(owner: UserInfo, name: String) {
        self.ownerId = owner.id
        self.name = name
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("ownerId", ownerId)
//        try row.set("memberIDs", try members.all().map {$0.idKey} )
//        try row.set("appIDs", try apps.all().map {$0.idKey})
        return row
    }
}

extension ProjectInfo: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { project in
            project.id()
            project.string("name")
            project.foreignId(for: UserInfo.self, optional: false, unique: false, foreignIdKey: "ownerId", foreignKeyName: "FK_UserInfo_ProjectInfo")
//            project.custom("members", type: "UserInfo")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension ProjectInfo: JSONConvertible {

    convenience init(json: JSON) throws {
        guard let ownerID = json["ownerID"]?.string,
                let owner = try UserInfo.find(ownerID),
                let name = json["name"]?.string else {
            throw Abort.badRequest
        }

        self.init(owner: owner, name: name)
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id?.string)
        try json.set("name", name)
        try json.set("memberIDs", try members.all().map {$0.idKey} )
        try json.set("appIDs", try apps.all().map {$0.idKey})

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
