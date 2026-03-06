import Foundation
import UIKit

public enum RouteTarget {
    case viewModel(RoutableViewModel.Type)
    case viewController((_ parameters: [String: Any]?) throws -> UIViewController)
    case action((_ context: RouteActionContext) throws -> Void)
}

public struct RouteActionContext {
    public let route: Route
    public let router: Router
    public let navigationController: RoutableNavigationController
    public let parameters: [String: Any]?
    public let isDeepLink: Bool
    public let animated: Bool

    public init(
        route: Route,
        router: Router,
        navigationController: RoutableNavigationController,
        parameters: [String: Any]?,
        isDeepLink: Bool,
        animated: Bool
    ) {
        self.route = route
        self.router = router
        self.navigationController = navigationController
        self.parameters = parameters
        self.isDeepLink = isDeepLink
        self.animated = animated
    }
}

public final class Route: Hashable {
    public let requiresAuthentication: Bool
    public let presentModally: Bool
    public let isRootRoute: Bool
    public let showTabBar: Bool?
    public let path: RoutePath
    public let target: RouteTarget

    public var type: RoutableViewModel.Type? {
        guard case let .viewModel(viewModelType) = target else { return nil }
        return viewModelType
    }

    public init(
        path: RoutePath,
        type: RoutableViewModel.Type,
        requiresAuthentication: Bool = true,
        presentModally: Bool = false,
        isRootRoute: Bool = false,
        showTabBar: Bool? = nil
    ) {
        self.path = path
        self.target = .viewModel(type)
        self.requiresAuthentication = requiresAuthentication
        self.presentModally = presentModally
        self.isRootRoute = isRootRoute
        self.showTabBar = showTabBar
    }

    public init(
        path: RoutePath,
        viewControllerFactory: @escaping (_ parameters: [String: Any]?) throws -> UIViewController,
        requiresAuthentication: Bool = true,
        presentModally: Bool = false,
        isRootRoute: Bool = false,
        showTabBar: Bool? = true
    ) {
        self.path = path
        self.target = .viewController(viewControllerFactory)
        self.requiresAuthentication = requiresAuthentication
        self.presentModally = presentModally
        self.isRootRoute = isRootRoute
        self.showTabBar = showTabBar
    }

    public init(
        path: RoutePath,
        action: @escaping (_ context: RouteActionContext) throws -> Void,
        requiresAuthentication: Bool = true,
        showTabBar: Bool? = nil
    ) {
        self.path = path
        self.target = .action(action)
        self.requiresAuthentication = requiresAuthentication
        self.presentModally = false
        self.isRootRoute = false
        self.showTabBar = showTabBar
    }

    public static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.path.path == rhs.path.path
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(path.path)
    }
}
