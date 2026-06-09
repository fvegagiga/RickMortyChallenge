import Foundation

struct PagedResult<T: Sendable>: Sendable {
    let items: [T]
    let hasNextPage: Bool
    let totalCount: Int
}
