import Foundation

struct Comment: Identifiable, Codable, Hashable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
}
