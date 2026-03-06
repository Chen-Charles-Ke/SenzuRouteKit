import SwiftUI

public protocol RoutableView where Self: View {
    associatedtype ViewModel: RoutableViewModel
    init(with viewModel: ViewModel)
    var viewModel: ViewModel { get }
}
