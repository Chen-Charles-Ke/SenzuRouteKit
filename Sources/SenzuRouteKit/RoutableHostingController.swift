import UIKit
import SwiftUI
import Combine

public final class RoutableHostingController: UIHostingController<AnyView> {
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

        viewModel.titleTextPublisher?
            .sink { [weak self] title in
                self?.navigationItem.title = title
            }
            .store(in: &bag)

        navigationController?.navigationBar.titleTextAttributes = viewModel.titleTextAttributes
        navigationController?.navigationBar.tintColor = viewModel.navigationBarTintColor
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        switch viewModel.navigationBarStyle {
        case .solid:
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationController?.navigationBar.barTintColor = viewModel.navigationBarBackgroundColor
            navigationController?.navigationBar.isTranslucent = false
        case .transparent:
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationController?.navigationBar.barTintColor = .clear
            navigationController?.navigationBar.isTranslucent = true
        case .hidden:
            navigationController?.setNavigationBarHidden(true, animated: false)
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

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
