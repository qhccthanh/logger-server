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

    let storage = Storage()
    let projectID: Identifier
    let ownerID: Identifier

    var name: String

    var logs: Children<AppInfo, LogInfo> {
        return children()
    }

    var project: Parent<AppInfo, ProjectInfo> {
        return parent(id: projectID)
    }

    var owner: Parent<AppInfo, UserInfo> {
        return parent(id: ownerID)
    }

    init(row: Row) throws {
        name        = try row.get("name")
        projectID   = try row.get("projectID")
        ownerID     = try row.get("ownerID")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)

        return row
    }
}
