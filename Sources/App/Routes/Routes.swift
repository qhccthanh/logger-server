import Vapor
import AuthProvider

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)

        // Middleware
        let authController = AuthContronller()
        self.post("signup", handler: authController.createUser)

        let tokenMiddleware = TokenAuthenticationMiddleware(UserInfo.self)
        let authedBuilder = self.grouped(tokenMiddleware)

        var protecedRoutes = [AuthRouterBuilderProtocol]()

        let userController = UserController()
        protecedRoutes.append(userController)

        let projectController = ProjectController()
        protecedRoutes.append(projectController)

        protecedRoutes.forEach {
            $0.addRoutes(builder: authedBuilder)
        }

    }
}

protocol AuthRouterBuilderProtocol {
    func addRoutes(builder: RouteBuilder)
}
