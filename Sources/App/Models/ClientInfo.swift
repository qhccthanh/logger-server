//
//  ClientInfo.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/19/18.
//

import Foundation
import Vapor
import FluentProvider

final class ClientInfo: Model {

    let storage         : Storage = Storage()
    var deviceID        : String // Primary key
    var deviceName      : String
    var appVersion      : String
    var appBuildVersion : String
    var isJailbroke     : Bool = false
    var ipAddress       : String?
    var userName        : String?
    var email           : String?
    var userID          : String?

    var projects: Children<ClientInfo, ProjectInfo> {
        return children()
    }

    init(row: Row) throws {

        deviceID        = try row.get("deviceID")
        deviceName      = try row.get("deviceName")
        appVersion      = try row.get("appVersion")
        appBuildVersion = try row.get("appBuildVersion")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        return row
    }
}
