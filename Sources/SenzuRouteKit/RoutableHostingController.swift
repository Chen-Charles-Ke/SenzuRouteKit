import UIKit
import SwiftUI
import Combine

public final class RoutableHostingController: UIHostingController<AnyView> {
    static weak var routeHandler: RouteHandler?

    public let path: RoutePath
    private let viewModel: RoutableViewModel
    private var bag = Set<AnyCancellable>()

    public init(with viewModel: RoutableViewModel, path: RoutePath) {
        self.viewModel = viewModel
        self.path = path
        super.init(rootView: viewModel.routedView)

        modalTransitionStyle = viewModel.modalTransitionStyle
        modalPresentationStyle = viewModel.modalPresentationStyle
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = viewModel.titleText
        bag.removeAll()

        viewModel.titleTextPublisher?
            .sink { [weak self] title in
                self?.navigationItem.title = title
            }
            .store(in: &bag)

        applyNavigationBarAppearance()

        if viewModel.enableNavItems {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: .init(systemName: "house.circle"),
                style: .plain,
                target: self,
                action: #selector(routeToLeftIcon)
            )

            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: .init(systemName: "person.circle"),
                style: .plain,
                target: self,
                action: #selector(routeToRightIcon)
            )
        }

        if let nav = navigationController as? RoutableNavigationController {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.viewModel.showTabBar ? nav.showTab(path: self.path) : nav.hideTabBar()
            }
        }
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        viewModel.preferredStatusBarStyle
    }

    @objc private func routeToLeftIcon() {
        Self.routeHandler?.leftCornerIcon()
    }

    @objc private func routeToRightIcon() {
        Self.routeHandler?.rightCornerIcon()
    }

    private func applyNavigationBarAppearance() {
        guard let navigationController else { return }

        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.titleTextAttributes = viewModel.titleTextAttributes

        switch viewModel.navigationBarStyle {
        case .solid:
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = viewModel.navigationBarBackgroundColor
            navigationController.navigationBar.isTranslucent = false
            navigationController.setNavigationBarHidden(false, animated: false)
        case .transparent:
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            navigationController.navigationBar.isTranslucent = true
            navigationController.setNavigationBarHidden(false, animated: false)
        case .hidden:
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            navigationController.navigationBar.isTranslucent = true
            navigationController.setNavigationBarHidden(true, animated: false)
        }

        let navigationBar = navigationController.navigationBar
        navigationBar.tintColor = viewModel.navigationBarTintColor
        navigationBar.titleTextAttributes = viewModel.titleTextAttributes
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
        navigationBar.layer.shadowOpacity = 0
        navigationBar.layer.shadowColor = UIColor.clear.cgColor
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
