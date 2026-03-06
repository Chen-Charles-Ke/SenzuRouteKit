import UIKit

public enum QuickRouter {
    @discardableResult
    public static func start(
        in window: UIWindow,
        startPath: RoutePath,
        routes: [Route],
        navType: RoutableNavigationController.Type = RouterNavigationController.self,
        animated: Bool = false
    ) -> NavigationRouter {
        let router = NavigationRouter(navType: navType, startPath: startPath)
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
