//
//  Request+Utility.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/23/18.
//

import Foundation
import Vapor
import FluentProvider

struct ResponseDefault {
    static var ok: ResponseRepresentable {
        return Response(status: .ok)
    }
}

extension Request {

    func getModelFromQueryParam<T: Model>(type: T.Type) throws ->  T {
        return try self.parameters.next(type.self)
    }

    func getStorage<T: Model>(type: T.Type) throws -> T {
        guard let model = self.storage[T.name] as? T else {
            throw Abort.notFound
        }

        return model
    }

    func getUser() throws -> UserInfo {
        return try self.auth.assertAuthenticated()
    }

}

extension Request {

    /// Create a post from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func getModelFromBody<T: JSONConvertible>(type: T.Type, appendJSON: [String: Any]? = nil) throws -> T {
        guard var json = self.json else {
            throw Abort.badRequest
        }

        if let appendJSON = appendJSON {
            for (key, value) in appendJSON {
                try json.set(key, value)
            }
        }

        return try T(json: json)
    }


}
