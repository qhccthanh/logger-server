//
//  CloudStrogeManager.swift
//  FileLoggerAPIPackageDescription
//
//  Created by Thanh Quach on 1/17/18.
//

import Foundation

protocol CloudStrogeProtocol {

    func createFolder(path: String)
    func isExisted(path: String)
    func createFile(path: String)
    func getFile(path: String)
    func searchFile(_ name: String)

    var autoCleanFileInterval: TimeInterval {get set}


}

class CloudStrogeManager {

}
