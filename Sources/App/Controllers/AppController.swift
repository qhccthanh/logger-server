//
//  AppController.swift
//  App
//
//  Created by Thanh Quach on 1/23/18.
//

import Foundation
import Vapor

final class AppController: AuthRouterBuilderProtocol {

    @discardableResult
    func addRoutes(builder: RouteBuilder) -> RouteBuilder {

        let appBulider = builder.grouped(ProjectInfo.parameter, "apps")

        let verifiedMemberAttachedMiddleware = VerifyOwnerRequestMiddleware<ProjectInfo>()
        verifiedMemberAttachedMiddleware.isVerifyBlock = {
            request, user, project in
            guard let user = user, let project = project else {
                return false
            }

            return try project.members.isAttached(user)
        }

        let appMemberVerifiedBuilder = appBulider.grouped(verifiedMemberAttachedMiddleware)

        // GET projects/:id/apps
        appMemberVerifiedBuilder.get(handler: getAll)

        // POST projects/:id/apps
        appMemberVerifiedBuilder.post(handler: create)

        let appDetailBuilder = appBulider.grouped(AppInfo.parameter)
        let verifiedOwnerMiddleware = VerifyOwnerRequestMiddleware<ProjectInfo>()
        verifiedOwnerMiddleware.isVerifyBlock = {
            request, user, project in
            guard let user = user, let _ = project else {
                return false
            }

            let app = try request.parameters.next(AppInfo.self)
            request.storage[AppInfo.name] = app

            return app.ownerId == user.id
        }

        let appDetailMemeberVerifiedBuilder = appDetailBuilder.grouped(verifiedMemberAttachedMiddleware)
        let appDetailOwnerVerifiedBuilder = appDetailBuilder.grouped(verifiedOwnerMiddleware)


        // GET projects/:id/apps/:id
        appDetailMemeberVerifiedBuilder.get(handler: get)

        // PUT projects/:id/apps/:id
        appDetailMemeberVerifiedBuilder.put(handler: update)

        // DELETE projects/:id/apps/:id
        appDetailOwnerVerifiedBuilder.get(handler: delete)

        return appBulider
    }

    // GET projects/:id/apps
    func getAll(_ req: Request) throws -> ResponseRepresentable {
        let project = try req.getStorage(type: ProjectInfo.self)
        let apps = try project.apps.all()

        return try apps.makeJSON()
    }

    // POST projects/:id/apps
    func create(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.getUser()
        let project  = try req.getStorage(type: ProjectInfo.self)

        let app = try req.getModelFromBody(type: AppInfo.self, appendJSON: [
                AppInfo.Keys.ownerID: user.id?.int ?? 0,
                AppInfo.Keys.projectID: project.id?.int ?? 0
            ])

        try app.save()
        return app
    }

    // GET projects/:id/apps/:id
    func get(_ req: Request) throws -> ResponseRepresentable {
        return try req.getStorage(type: AppInfo.self)
    }

    // PUT projects/:id/apps/:id
    func update(_ req: Request) throws -> ResponseRepresentable {
        let app = try req.getStorage(type: AppInfo.self)
        try app.update(for: req)
        try app.save()
        return app
    }

    // DELETE projects/:id/apps/:id
    func delete(_ req: Request) throws -> ResponseRepresentable {
        let app = try req.getStorage(type: AppInfo.self)
        try app.delete()
        return ResponseDefault.ok
    }
    
}
