//
//  Routes+Auth.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/17/18.
//

import Foundation
import Vapor

extension Droplet {

    func setupAuthRouter() {

        post("/auth") {
            req in

            let receiJSON = try! JSON.init(bytes: req.body.bytes!)
            print(receiJSON)

            var json = JSON()
            try json.set("abc", "xyc")
            return json
        }

    }

}
