//
//  VerifyOwnerRequestMiddleware.swift
//  App
//
//  Created by Thanh Quach on 1/24/18.
//

import Foundation
import Vapor
import HTTP
import FluentProvider

final class VerifyOwnerRequestMiddleware<T: Model>: Middleware {

    var isVerifyBlock: ((_ request: Request,_ user: UserInfo?,_ info: T?) throws -> Bool)?

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let info = try request.parameters.next(T.self)
        let user = try request.getUser()
        request.storage[T.name] = info
        request.storage[UserInfo.name] = info

        if !(try isVerifyBlock?(request, user, info) ?? true) {
            throw Abort(.forbidden)
        }

        return try next.respond(to: request)
    }

}
