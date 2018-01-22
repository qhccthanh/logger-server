//
//  LogInfo.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/19/18.
//

import Foundation
import Vapor
import FluentProvider

final class LogInfo: Model {

    enum LogType: Int {
        case verbose
        case info
        case error
        case warn
        case http
        case file
        case database
    }

    let storage = Storage()
    let clientID: Identifier

    var type: LogType
    var fromDate: Date
    var toDate: Date
    var url: String?

    var client: Parent<LogInfo,ClientInfo> {
        return parent(id: clientID)
    }

    init(row: Row) throws {
        type = try row.get("type")
        fromDate = try row.get("fromDate")
        toDate = try row.get("toDate")
        clientID = try row.get("clientID")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("clientID", clientID)
        return row
    }
}
