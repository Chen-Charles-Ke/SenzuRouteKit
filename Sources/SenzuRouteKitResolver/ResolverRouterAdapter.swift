import Resolver
import SenzuRouteKit

public enum SenzuRouteKitResolverAdapter {
    @discardableResult
    public static func registerRouter(
        navType: RoutableNavigationController.Type,
        startPath: RoutePath,
        routeHandler: RouteHandler,
        scope: ResolverScope = .application
    ) -> ResolverOptions<Router> {
        Resolver.register {
            NavigationRouter(
                navType: navType,
                startPath: startPath,
                routeHandler: routeHandler
            ) as Router
        }
        .scope(scope)
    }
}

public extension Resolver {
    @discardableResult
    static func registerSenzuRouter(
        navType: RoutableNavigationController.Type,
        startPath: RoutePath,
        routeHandler: RouteHandler,
        scope: ResolverScope = .application
    ) -> ResolverOptions<Router> {
        SenzuRouteKitResolverAdapter.registerRouter(
            navType: navType,
            startPath: startPath,
            routeHandler: routeHandler,
            scope: scope
        )
    }
}
