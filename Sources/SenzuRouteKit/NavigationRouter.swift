import UIKit

public final class NavigationRouter: Router {
    public lazy var nav: RoutableNavigationController = {
        navType.init()
    }()

    public let startPath: RoutePath
    public let routeHandler: RouteHandler

    private let navType: RoutableNavigationController.Type
    private var currentPath: RoutePath
    private var routes: [String: Route] = [:]

    public init(
        navType: RoutableNavigationController.Type,
        startPath: RoutePath,
        routeHandler: RouteHandler
    ) {
        self.navType = navType
        self.startPath = startPath
        self.currentPath = startPath
        self.routeHandler = routeHandler
        RoutableHostingController.routeHandler = routeHandler
    }

    public func bind(route: Route) {
        guard routes[route.path.path] == nil else { return }
        routes[route.path.path] = route
    }

    public func bind(routes: [Route]) {
        routes.forEach(bind(route:))
    }

    public func unbind(route: Route) {
        routes.removeValue(forKey: route.path.path)
    }

    public func unbind(routes: [Route]) {
        routes.forEach(unbind(route:))
    }

    public func unbindAll() {
        routes.removeAll()
    }

    public func route(
        to path: RoutePath,
        parameters: [String : Any]?,
        isDeepLink: Bool,
        animated: Bool
    ) {
        guard let route = routes[path.path] else {
            assertionFailure("Route not found: \(path.path)")
            return
        }

        guard let viewModel = try? route.type.init(parameters: parameters) else {
            assertionFailure("Failed to create viewModel for route: \(path.path)")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentPath = path

            if !route.presentModally {
                self.nav.dismiss(animated: true, completion: nil)

                let viewControllers = self.nav.viewControllers
                    .compactMap { $0 as? RoutableHostingController }

                if let found = viewControllers.first(where: { $0.path.path == route.path.path }) {
                    self.nav.popToViewController(found, animated: animated)
                    return
                }

                let controller = RoutableHostingController(with: viewModel, path: route.path)
                if viewModel.isRootView {
                    self.nav.popToRootViewController(animated: false)
                    if self.nav.viewControllers.isEmpty {
                        self.nav.viewControllers = [controller]
                    } else {
                        self.nav.viewControllers[0] = controller
                    }
                } else {
                    self.nav.pushViewController(controller, animated: animated)
                }
            } else {
                let controller = RoutableHostingController(with: viewModel, path: route.path)
                self.topController?.present(controller, animated: animated, completion: nil)
            }
        }
    }

    public func dismiss(animated: Bool) {
        guard let route = routes[currentPath.path] else { return }

        if route.presentModally {
            topController?.dismiss(animated: animated, completion: nil)
        } else {
            _ = nav.popViewController(animated: animated)
        }
    }

    public func logout() {
        start()
    }

    private var topController: UIViewController? {
        guard var top = nav.visibleViewController else { return nil }
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
