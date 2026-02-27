import Foundation

struct Album: Identifiable, Codable, Hashable {
    let id: Int
    let userId: Int
    let title: String
}
