import Foundation

public struct DeepLinkDestination {
    public let path: RoutePath
    public let parameters: [String: Any]
    public let animated: Bool

    public init(
        path: RoutePath,
        parameters: [String: Any] = [:],
        animated: Bool = true
    ) {
        self.path = path
        self.parameters = parameters
        self.animated = animated
    }
}

public protocol DeepLinkParser {
    func parse(url: URL) -> DeepLinkDestination?
}

public struct DeepLinkRule {
    public let pattern: URLPattern
    public let transform: (URLPattern.Match) -> DeepLinkDestination?

    public init(
        pattern: URLPattern,
        transform: @escaping (URLPattern.Match) -> DeepLinkDestination?
    ) {
        self.pattern = pattern
        self.transform = transform
    }
}

public struct StandardDeepLinkParser: DeepLinkParser {
    public let rules: [DeepLinkRule]

    public init(rules: [DeepLinkRule]) {
        self.rules = rules
    }

    public func parse(url: URL) -> DeepLinkDestination? {
        for rule in rules {
            guard let match = rule.pattern.match(url: url) else { continue }
            if let destination = rule.transform(match) {
                return destination
            }
        }
        return nil
    }
}
