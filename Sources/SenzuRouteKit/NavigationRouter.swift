import UIKit
import ObjectiveC

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

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentPath = path

            switch route.target {
            case let .viewModel(viewModelType):
                self.handleViewModelRoute(
                    route: route,
                    viewModelType: viewModelType,
                    parameters: parameters,
                    animated: animated
                )
            case let .viewController(factory):
                self.handleUIViewControllerRoute(
                    route: route,
                    factory: factory,
                    parameters: parameters,
                    animated: animated
                )
            case let .action(action):
                self.handleActionRoute(
                    route: route,
                    action: action,
                    parameters: parameters,
                    isDeepLink: isDeepLink,
                    animated: animated
                )
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

    private func handleViewModelRoute(
        route: Route,
        viewModelType: RoutableViewModel.Type,
        parameters: [String: Any]?,
        animated: Bool
    ) {
        guard let viewModel = try? viewModelType.init(parameters: parameters) else {
            assertionFailure("Failed to create viewModel for route: \(route.path.path)")
            return
        }

        let controller = RoutableHostingController(with: viewModel, path: route.path)
        controller.senzuRoutePath = route.path.path

        updateTabVisibility(for: route, fallbackVisibility: viewModel.showTabBar)
        navigateToController(
            controller,
            route: route,
            animated: animated,
            isRootRoute: route.isRootRoute || viewModel.isRootView
        )
    }

    private func handleUIViewControllerRoute(
        route: Route,
        factory: (_ parameters: [String: Any]?) throws -> UIViewController,
        parameters: [String: Any]?,
        animated: Bool
    ) {
        guard let controller = try? factory(parameters) else {
            assertionFailure("Failed to create UIViewController for route: \(route.path.path)")
            return
        }

        controller.senzuRoutePath = route.path.path
        updateTabVisibility(for: route, fallbackVisibility: true)
        navigateToController(
            controller,
            route: route,
            animated: animated,
            isRootRoute: route.isRootRoute
        )
    }

    private func handleActionRoute(
        route: Route,
        action: (_ context: RouteActionContext) throws -> Void,
        parameters: [String: Any]?,
        isDeepLink: Bool,
        animated: Bool
    ) {
        if let visibility = route.showTabBar {
            visibility ? nav.showTab(path: route.path) : nav.hideTabBar()
        }

        let context = RouteActionContext(
            route: route,
            router: self,
            navigationController: nav,
            parameters: parameters,
            isDeepLink: isDeepLink,
            animated: animated
        )

        do {
            try action(context)
        } catch {
            assertionFailure("Failed to execute action for route \(route.path.path): \(error)")
        }
    }

    private func updateTabVisibility(for route: Route, fallbackVisibility: Bool) {
        let shouldShowTabBar = route.showTabBar ?? fallbackVisibility
        shouldShowTabBar ? nav.showTab(path: route.path) : nav.hideTabBar()
    }

    private func navigateToController(
        _ controller: UIViewController,
        route: Route,
        animated: Bool,
        isRootRoute: Bool
    ) {
        if route.presentModally {
            topController?.present(controller, animated: animated, completion: nil)
            return
        }

        nav.dismiss(animated: true, completion: nil)

        if let found = nav.viewControllers.first(where: { $0.senzuRoutePath == route.path.path }) {
            nav.popToViewController(found, animated: animated)
            return
        }

        if isRootRoute {
            nav.popToRootViewController(animated: false)
            if nav.viewControllers.isEmpty {
                nav.viewControllers = [controller]
            } else {
                nav.viewControllers[0] = controller
            }
            return
        }

        nav.pushViewController(controller, animated: animated)
    }
}

private var routePathAssociationKey: UInt8 = 0

private extension UIViewController {
    var senzuRoutePath: String? {
        get {
            objc_getAssociatedObject(self, &routePathAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(
                self,
                &routePathAssociationKey,
                newValue,
                .OBJC_ASSOCIATION_COPY_NONATOMIC
            )
        }
    }
}
