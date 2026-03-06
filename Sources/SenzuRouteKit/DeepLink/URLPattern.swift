import Foundation

public struct URLPattern {
    public struct Match {
        public let url: URL
        public let pathParameters: [String: String]
        public let queryParameters: [String: String]

        public init(url: URL,
                    pathParameters: [String: String],
                    queryParameters: [String: String]) {
            self.url = url
            self.pathParameters = pathParameters
            self.queryParameters = queryParameters
        }

        public func value(for key: String) -> String? {
            if let value = pathParameters[key] {
                return value
            }
            return queryParameters[key]
        }
    }

    public let schemes: Set<String>
    public let hosts: Set<String>
    public let pathTemplate: String

    public init(
        schemes: [String] = [],
        hosts: [String] = [],
        pathTemplate: String
    ) {
        self.schemes = Set(schemes.map { $0.lowercased() })
        self.hosts = Set(hosts.map { $0.lowercased() })
        self.pathTemplate = pathTemplate
    }

    public func match(url: URL) -> Match? {
        if !schemes.isEmpty {
            let urlScheme = (url.scheme ?? "").lowercased()
            guard schemes.contains(urlScheme) else { return nil }
        }

        if !hosts.isEmpty {
            let urlHost = (url.host ?? "").lowercased()
            guard hosts.contains(urlHost) else { return nil }
        }

        let urlSegments = normalize(path: url.path)
        let templateSegments = normalize(path: pathTemplate)

        guard urlSegments.count == templateSegments.count else {
            return nil
        }

        var pathParameters: [String: String] = [:]

        for (template, segment) in zip(templateSegments, urlSegments) {
            if template.hasPrefix(":") {
                let key = String(template.dropFirst())
                pathParameters[key] = segment
                continue
            }

            if template != segment {
                return nil
            }
        }

        var query: [String: String] = [:]
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let items = components.queryItems {
            for item in items {
                query[item.name] = item.value ?? ""
            }
        }

        return Match(url: url, pathParameters: pathParameters, queryParameters: query)
    }

    private func normalize(path: String) -> [String] {
        path
            .split(separator: "/")
            .map(String.init)
    }
}
