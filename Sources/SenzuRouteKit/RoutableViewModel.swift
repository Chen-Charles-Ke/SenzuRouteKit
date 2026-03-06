import UIKit
import SwiftUI
import Combine

public enum NavigationBarStyle {
    case solid
    case transparent
    case hidden
}

public protocol RoutableViewModel {
    init(parameters: [String: Any]?) throws

    var routedView: AnyView { get }
    var isRootView: Bool { get }
    var enableNavItems: Bool { get }
    var preferredStatusBarStyle: UIStatusBarStyle { get }
    var navigationBarStyle: NavigationBarStyle { get }
    var navigationBarTintColor: UIColor { get }
    var navigationBarBackgroundColor: UIColor { get }
    var titleText: String { get }
    var titleTextPublisher: Published<String>.Publisher? { get }
    var titleTextAttributes: [NSAttributedString.Key: Any] { get }
    var showTabBar: Bool { get }
    var modalTransitionStyle: UIModalTransitionStyle { get }
    var modalPresentationStyle: UIModalPresentationStyle { get }
}

public extension RoutableViewModel {
    var isRootView: Bool { false }
    var enableNavItems: Bool { false }
    var preferredStatusBarStyle: UIStatusBarStyle { .default }
    var navigationBarStyle: NavigationBarStyle { .solid }
    var navigationBarTintColor: UIColor { .black }
    var navigationBarBackgroundColor: UIColor { .white }
    var titleText: String { "" }
    var titleTextPublisher: Published<String>.Publisher? { nil }
    var titleTextAttributes: [NSAttributedString.Key: Any] {
        [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ]
    }
    var showTabBar: Bool { false }
    var modalTransitionStyle: UIModalTransitionStyle { .coverVertical }
    var modalPresentationStyle: UIModalPresentationStyle { .pageSheet }
}
