//
//  ProjectController.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/22/18.
//

import Foundation
import Vapor

final class ProjectController: AuthRouterBuilderProtocol {

    @discardableResult
    func addRoutes(builder: RouteBuilder) -> RouteBuilder {
        let basic = builder.grouped("projects")
        
        // GET /projects getAll
        basic.get(handler: index)

        // POST /projects create
        basic.post(handler: store)

        // Verified owner user
        let verifiedMemberAttachedMiddleware = VerifyOwnerRequestMiddleware<ProjectInfo>()
        verifiedMemberAttachedMiddleware.isVerifyBlock = {
            request, user, project in
            guard let user = user, let project = project else {
                return false
            }

            return try project.members.isAttached(user)
        }

        let verifiedOwnerMiddleware = VerifyOwnerRequestMiddleware<ProjectInfo>()
        verifiedOwnerMiddleware.isVerifyBlock = {
            request, user, project in
            guard let user = user, let project = project else {
                return false
            }

            return project.ownerId == user.id
        }

        let verifiedMemberBuilder = basic.grouped(verifiedMemberAttachedMiddleware)
        let verifiedOwnerBuilder = basic.grouped(verifiedOwnerMiddleware)

        // GET /projects/:id get item
        verifiedMemberBuilder.get(ProjectInfo.parameter,handler: show)

        // PUT /projects/:id update item
        verifiedOwnerBuilder.put(ProjectInfo.parameter,handler: update)

        // DELETE /projects/:id update item
        verifiedOwnerBuilder.delete(ProjectInfo.parameter,handler: delete)


        let verifyOwnerInMemberAPIBuilder = verifiedOwnerBuilder.grouped(ProjectInfo.parameter, "members")
        let verifyMemberInMemberAPIBuilder = verifiedMemberBuilder.grouped(ProjectInfo.parameter, "members")

        // GET /project/:id/members
        verifyMemberInMemberAPIBuilder.get(handler: getMemebers)

        // POST /projects/:id/members/:id
        verifyOwnerInMemberAPIBuilder.post(UserInfo.parameter, handler: addMemeber)

        // DELETE /projects/:id/members/:id
        verifyOwnerInMemberAPIBuilder.delete(UserInfo.parameter, handler: deleteMemeber)

        return basic
    }

    // GET /projects getAll
    func index(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.getUser()
        return try user.projects.all().makeJSON()
    }

     // POST /projects create
    func store(_ req: Request) throws -> ResponseRepresentable {

        let user = try req.getUser()
        let project = try req.getModelFromBody(type: ProjectInfo.self, appendJSON: [
            ProjectInfo.Keys.ownerId: user.id?.int ?? 0
            ])
        try project.save()
        try project.members.add(user)
        return project
    }

    // GET /projects/:id get item
    func show(_ req: Request) throws -> ResponseRepresentable {
        let info = try req.getStorage(type: ProjectInfo.self)
        return info
    }

    // DELETE /projects/:id Delete item
    func delete(_ req: Request) throws -> ResponseRepresentable {

        let info = try req.getStorage(type: ProjectInfo.self)

        try info.delete()
        return ResponseDefault.ok
    }

    // PUT /projects/:id update item
    func update(_ req: Request) throws -> ResponseRepresentable {
        // See `extension Post: Updateable`
        let info = try req.getStorage(type: ProjectInfo.self)
        try info.update(for: req)
        // Save an return the updated post.
        try info.save()
        return info
    }

    // GET /project/:id/members
    func getMemebers(_ req: Request) throws -> ResponseRepresentable {
        let info = try req.getStorage(type: ProjectInfo.self)

        return try info.members.all().makeJSON()
    }

    // POST /projects/:id/members/:id Add Memeber
    func addMemeber(_ req: Request) throws -> ResponseRepresentable {
        let info = try req.getStorage(type: ProjectInfo.self)
        let addMember = try req.getModelFromQueryParam(type: UserInfo.self)

        try info.members.add(addMember)
        try info.save()
        return ResponseDefault.ok
    }

    // DELETE /projects/:id/members/:id
    func deleteMemeber(_ req: Request) throws -> ResponseRepresentable {
        let info = try req.getStorage(type: ProjectInfo.self)
        let removeMember = try req.getModelFromQueryParam(type: UserInfo.self)

        if info.ownerId == removeMember.id {
            throw Abort.init(.badRequest,
                            reason: "Cannot remove owner",
                            identifier: "error_owner_remove")

        }

        try info.members.remove(removeMember)
        return ResponseDefault.ok
    }
}
