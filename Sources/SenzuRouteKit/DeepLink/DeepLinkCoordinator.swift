import Foundation

public final class DeepLinkCoordinator {
    private let parser: DeepLinkParser
    private let routerProvider: () -> Router?
    private var pendingURLs: [URL] = []

    public init(
        parser: DeepLinkParser,
        routerProvider: @escaping () -> Router?
    ) {
        self.parser = parser
        self.routerProvider = routerProvider
    }

    @discardableResult
    public func handle(url: URL) -> Bool {
        guard let destination = parser.parse(url: url) else {
            return false
        }

        guard let router = routerProvider() else {
            pendingURLs.append(url)
            return true
        }

        router.navigate(
            to: destination.path,
            parameters: destination.parameters,
            isDeepLink: true,
            animated: destination.animated
        )
        return true
    }

    @discardableResult
    public func handle(userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        return handle(url: url)
    }

    public func flushPending() {
        guard !pendingURLs.isEmpty else { return }
        let urls = pendingURLs
        pendingURLs.removeAll()
        urls.forEach { _ = handle(url: $0) }
    }
}
