import Foundation

struct PaginatedResponseDTO<T: Decodable>: Decodable {
    let info: PaginationInfoDTO
    let results: [T]
}

struct PaginationInfoDTO: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
