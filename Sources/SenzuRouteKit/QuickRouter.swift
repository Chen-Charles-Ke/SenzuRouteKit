import UIKit

public enum QuickRouter {
    private final class DefaultRouteHandler: RouteHandler {
        func leftCornerIcon() {}
        func rightCornerIcon() {}
    }

    @discardableResult
    public static func start(
        in window: UIWindow,
        startPath: RoutePath,
        routes: [Route],
        navType: RoutableNavigationController.Type = RouterNavigationController.self,
        routeHandler: RouteHandler? = nil,
        animated: Bool = false
    ) -> NavigationRouter {
        let resolvedHandler = routeHandler ?? DefaultRouteHandler()
        let router = NavigationRouter(
            navType: navType,
            startPath: startPath,
            routeHandler: resolvedHandler
        )
        router.bind(routes: routes)
        guard let navController = router.nav as? UIViewController else {
            fatalError("RoutableNavigationController must be a UIViewController")
        }
        window.rootViewController = navController
        window.makeKeyAndVisible()
        router.start(animated: animated)
        return router
    }
}
