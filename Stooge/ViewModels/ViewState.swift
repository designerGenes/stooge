import Foundation

enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case failed(Error)

    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.loaded, .loaded):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }

    var errorMessage: String? {
        if case .failed(let error) = self {
            return error.localizedDescription
        }
        return nil
    }
}
