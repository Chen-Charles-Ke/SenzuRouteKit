import Resolver

public enum SenzuDIScope {
    case application
    case cached
    case graph
    case shared
    case unique

    var resolverScope: ResolverScope {
        switch self {
        case .application:
            return .application
        case .cached:
            return .cached
        case .graph:
            return .graph
        case .shared:
            return .shared
        case .unique:
            return .unique
        }
    }
}

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
        scope: SenzuDIScope = .application
    ) -> ResolverOptions<Service> {
        Resolver.register { factory() }
            .scope(scope.resolverScope)
    }

    public static func resolve<Service>(_ type: Service.Type = Service.self) -> Service {
        Resolver.resolve(type)
    }

    @discardableResult
    public static func registerRouter(
        navType: RoutableNavigationController.Type,
        startPath: RoutePath,
        routeHandler: RouteHandler,
        scope: SenzuDIScope = .application
    ) -> ResolverOptions<Router> {
        Resolver.register {
            NavigationRouter(
                navType: navType,
                startPath: startPath,
                routeHandler: routeHandler
            ) as Router
        }
        .scope(scope.resolverScope)
    }
}
