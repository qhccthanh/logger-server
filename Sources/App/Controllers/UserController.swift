//
//  UserController.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/22/18.
//

import Foundation
import Vapor

final class UserController: AuthRouterBuilderProtocol {

    @discardableResult
    func addRoutes(builder: RouteBuilder) -> RouteBuilder {
        let basic = builder.grouped("users")

        // GET users/
        basic.get(handler: index)
//        basic.post(handler: store)

//        basic.delete(handler: clear)

        // GET users/:id
        basic.get(UserInfo.parameter, handler: show)

        // PUT users/:id
        basic.put(UserInfo.parameter, handler: update)

        // DELETE users/:id
//        basic.delete(UserInfo.parameter, handler: delete)
        return basic
    }

    /// When users call 'GET' on '/posts'
    /// it should return an index of all available posts
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try UserInfo.all().makeJSON()
    }

    /// When consumers call 'POST' on '/posts' with valid JSON
    /// construct and save the post
    func store(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.getModelFromBody(type: UserInfo.self)
        try user.save()
        return user
    }

    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
    func show(_ req: Request) throws -> ResponseRepresentable {
        let userInfo = try req.parameters.next(UserInfo.self)
        return userInfo
    }

    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(_ req: Request) throws -> ResponseRepresentable {
        let userInfo = try req.getModelFromQueryParam(type: UserInfo.self)
        try userInfo.delete()
        return Response(status: .ok)
    }

    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/posts' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try UserInfo.makeQuery().delete()
        return Response(status: .ok)
    }

    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request) throws -> ResponseRepresentable {

        let userInfo = try req.getModelFromQueryParam(type: UserInfo.self)
        try userInfo.update(for: req)
        let user = try req.getUser()
        
        if user.id != userInfo.id {
            throw Abort(.forbidden)
        }

        try user.save()
        return userInfo
    }
}

// MARK: EmptyInitializable
extension UserController: EmptyInitializable {}
