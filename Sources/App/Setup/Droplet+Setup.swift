@_exported import Vapor

extension Droplet {
    public func setup() throws {
        try setupRoutes()
        // Do any additional droplet setup
        setupAuthRouter()
        Droplet.shared = self
    }

    public static var shared: Droplet?
}
