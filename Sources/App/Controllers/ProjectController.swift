//
//  ProjectController.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/22/18.
//

import Foundation
import Vapor

final class ProjectController: AuthRouterBuilderProtocol {

    func addRoutes(builder: RouteBuilder) {
        let basic = builder.grouped("projects")

        // GET /projects getAll
        basic.get(handler: index)

        // POST /projects create
        basic.post(handler: store)

        // GET /projects/:id get item
        basic.get(ProjectInfo.parameter,handler: show)

        // PUT /projects/:id update item
        basic.put(ProjectInfo.parameter,handler: update)

        // DELETE /projects/:id update item
        basic.delete(ProjectInfo.parameter,handler: delete)
    }

    func index(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.getUser()
        return try user.projects.all().makeJSON()
    }

    /// When consumers call 'POST' on '/posts' with valid JSON
    /// construct and save the post
    func store(_ req: Request) throws -> ResponseRepresentable {

        let user = try req.getUser()
        let project = try req.getModelFromBody(type: ProjectInfo.self, appendJSON: [
            ProjectInfo.Keys.ownerId: user.id?.int ?? 0
            ])
        try project.save()
        return project
    }

    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
    func show(_ req: Request) throws -> ResponseRepresentable {
        let info = try req.getModelFromQueryParam(type: ProjectInfo.self)
        return info
    }

    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(_ req: Request) throws -> ResponseRepresentable {
        let info = try req.parameters.next(ProjectInfo.self)
        try info.delete()
        return Response(status: .ok)
    }

    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request) throws -> ResponseRepresentable {
        // See `extension Post: Updateable`
        let info = try req.parameters.next(ProjectInfo.self)
        try info.update(for: req)

        // Save an return the updated post.
        try info.save()
        return info
    }

}
