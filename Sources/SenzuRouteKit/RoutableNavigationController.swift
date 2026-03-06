import UIKit

public protocol RoutableNavigationController where Self: UINavigationController {
    init()
    var viewControllers: [UIViewController] { get set }
    var visibleViewController: UIViewController? { get }

    func showTab(path: RoutePath)
    func hideTabBar()
    func reloadTabs()

    func dismiss(animated: Bool, completion: (() -> Void)?)
    func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]?
    func popToRootViewController(animated: Bool) -> [UIViewController]?
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    func popViewController(animated: Bool) -> UIViewController?
}
