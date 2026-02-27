import Foundation

struct Photo: Identifiable, Codable, Hashable {
    let id: Int
    let albumId: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}
