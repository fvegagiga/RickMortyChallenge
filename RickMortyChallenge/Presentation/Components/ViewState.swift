import Foundation

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case empty
    case failure(Error)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var successValue: T? {
        if case .success(let value) = self { return value }
        return nil
    }

    var error: Error? {
        if case .failure(let error) = self { return error }
        return nil
    }
}
