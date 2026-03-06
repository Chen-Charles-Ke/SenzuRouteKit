import Resolver

public typealias SenzuScope = ResolverScope

@propertyWrapper
public struct SenzuInjected<Service> {
    private var service: Service

    public init() {
        service = Resolver.resolve(Service.self)
    }

    public var wrappedValue: Service {
        get { service }
        mutating set { service = newValue }
    }
}

public enum SenzuDI {
    @discardableResult
    public static func register<Service>(
        _ factory: @escaping () -> Service,
        scope: ResolverScope = .application
    ) -> ResolverOptions<Service> {
        Resolver.register { factory() }
            .scope(scope)
    }

    public static func resolve<Service>(_ type: Service.Type = Service.self) -> Service {
        Resolver.resolve(type)
    }

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
