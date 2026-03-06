import Foundation

public protocol Router: AnyObject {
    var nav: RoutableNavigationController { get }
    var startPath: RoutePath { get }

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
