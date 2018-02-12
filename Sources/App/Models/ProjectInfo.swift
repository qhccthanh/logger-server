//
//  Project.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/19/18.
//

import Foundation
import Vapor
import FluentProvider

final class ProjectMember: Model, Preparation, PivotProtocol {

    static var leftIdKey: String = Keys.projectId
    static var rightIdKey: String = Keys.userId

    typealias Left = ProjectInfo
    typealias Right = UserInfo

    struct Keys {
        static let userId = "user_info_id"
        static let projectId = "project_info_id"
    }

    let storage: Storage = Storage()
    let projectId: Identifier
    let userId: Identifier

    var userInfo: Parent<ProjectMember, UserInfo> {
        return parent(id: userId)
    }

    var projectInfo: Parent<ProjectMember, ProjectInfo> {
        return parent(id: projectId)
    }

    init(row: Row) throws {
        projectId = try row.get(Keys.projectId)
        userId = try row.get(Keys.userId)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.projectId, projectId)
        try row.set(Keys.userId, userId)
        return row
    }

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
//            builder.foreignId(for: ProjectInfo.self, optional: false, unique: false, foreignIdKey: Keys.projectId)
//            builder.int(Keys.projectId)
            builder.parent(ProjectInfo.self, optional: false, unique: false, foreignIdKey: Keys.projectId)
//            builder.foreignId(for: UserInfo.self, optional: false, unique: false, foreignIdKey: Keys.userId)
            builder.parent(UserInfo.self, optional: false, unique: false, foreignIdKey: Keys.userId)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

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

    var members: Siblings<ProjectInfo, UserInfo, ProjectMember> {
        return siblings()
    }

    var apps: Children<ProjectInfo,AppInfo> {
        return children(type: AppInfo.self, foreignIdKey: AppInfo.Keys.projectID)
    }

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
        try json.set(Keys.id, id?.int)
        try json.set(Keys.name, name)
        try json.set(Keys.ownerId, ownerId.int)
        try json.set(Keys.memberIds, try members.all().map {[
            UserInfo.Keys.id: $0.id?.int ?? 0,
            UserInfo.Keys.name: $0.name,
            UserInfo.Keys.email: $0.email
            ]})
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
