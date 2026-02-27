import Foundation

struct Post: Identifiable, Codable, Hashable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
