import Foundation

public protocol RouteHandler: AnyObject {
    func leftCornerIcon()
    func rightCornerIcon()
}

public protocol AuthHandler {
    var isAuthenticated: Bool { get }
    func performLogin(nextPath: RoutePath, isDeepLink: Bool)
    func performLogout()
}

public protocol Router: AnyObject {
    var nav: RoutableNavigationController { get }
    var startPath: RoutePath { get }
    var routeHandler: RouteHandler { get }

    init(
        navType: RoutableNavigationController.Type,
        startPath: RoutePath,
        routeHandler: RouteHandler
    )

    func bind(route: Route)
    func bind(routes: [Route])
    func unbind(route: Route)
    func unbind(routes: [Route])
    func unbindAll()

    func route(to path: RoutePath,
               parameters: [String: Any]?,
               isDeepLink: Bool,
               animated: Bool)

    func dismiss(animated: Bool)
    func logout()
}

public extension Router {
    func navigate(to path: RoutePath,
                  parameters: [String: Any]? = nil,
                  isDeepLink: Bool = false,
                  animated: Bool = true) {
        route(to: path,
              parameters: parameters,
              isDeepLink: isDeepLink,
              animated: animated)
    }

    func start(animated: Bool = false) {
        navigate(to: startPath, animated: animated)
    }
}
