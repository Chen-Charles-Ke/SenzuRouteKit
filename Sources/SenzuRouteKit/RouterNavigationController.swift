import UIKit

open class RouterNavigationController: UINavigationController, RoutableNavigationController {
    public required init() {
        let placeholder = UIViewController()
        placeholder.view.backgroundColor = .systemBackground
        super.init(rootViewController: placeholder)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func showTab(path: RoutePath) {}
    open func hideTabBar() {}
    open func reloadTabs() {}
}
