//
//  AuthController.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/17/18.
//

import Foundation
import Vapor

final class AuthContronller {

    // Create User
    func createUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.getModel(type: UserInfo.self)
        try user.save()

        let token = SimpleToken(user: user)
        try token.save()

        var json = JSON()
        try json.set("user", try user.makeJSON())
        try json.set("token",token.string)
        return try Response(status: .ok, json: json)
    }

}
