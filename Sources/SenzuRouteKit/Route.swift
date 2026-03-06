import Foundation

public final class Route: Hashable {
    public let requiresAuthentication: Bool
    public let presentModally: Bool
    public let path: RoutePath
    public let type: RoutableViewModel.Type

    public init(
        path: RoutePath,
        type: RoutableViewModel.Type,
        requiresAuthentication: Bool = true,
        presentModally: Bool = false
    ) {
        self.path = path
        self.type = type
        self.requiresAuthentication = requiresAuthentication
        self.presentModally = presentModally
    }

    public static func == (lhs: Route, rhs: Route) -> Bool {
        lhs.path.path == rhs.path.path
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(path.path)
    }
}
