//
//  ResponseMiddleware.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/23/18.
//

import Foundation
import Vapor
import HTTP

final class ResponseMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            let response = try next.respond(to: request)

            //        print(response.json)
            var responseJSON = JSON()
            try responseJSON.set("result", response.status.serverErrorCode)
            try responseJSON.set("reply", response.json)
            response.body = responseJSON.makeBody()
            return response
        } catch let error {
            var responseCode: String = error.localizedDescription
            if let abort = error as? Vapor.Abort {
                responseCode = abort.status.serverErrorCode
            }

            var responseJSON = JSON()
            try responseJSON.set("result", responseCode)
            try responseJSON.set("reply", "")

            let response = Response(status: .ok, body: responseJSON.makeBody())
            return response
        }
    }
}

extension HTTP.Status {

    var serverErrorCode: String {
        switch self {
        case .ok:
            return "success"
        case .unauthorized:
            return "error_access_token"
        case .badRequest:
            return "error_bad_request"
        case .notFound:
            return "error_not_found"
        case .forbidden:
            return "error_forbidden"
        case .internalServerError:
            return "error_server"
        case .requestTimeout:
            return "error_timeout"
        case .badGateway:
            return "error_bad_gateway"
        case .requestURITooLong:
            return "error_uri_too_long"
        default:
            return "error_unknow_error"
        }
    }
}
