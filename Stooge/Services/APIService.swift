import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse(Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse(let code):
            return "Server returned status \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

final class APIService {
    static let shared = APIService()

    private let baseURL = "https://jsonplaceholder.typicode.com"
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Core

    private func fetch<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.networkError(error)
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw APIError.invalidResponse(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Posts

    func fetchPosts() async throws -> [Post] {
        try await fetch("/posts")
    }

    func fetchPost(id: Int) async throws -> Post {
        try await fetch("/posts/\(id)")
    }

    func fetchComments(forPost postId: Int) async throws -> [Comment] {
        try await fetch("/posts/\(postId)/comments")
    }

    func fetchPosts(byUser userId: Int) async throws -> [Post] {
        try await fetch("/users/\(userId)/posts")
    }

    // MARK: - Users

    func fetchUsers() async throws -> [User] {
        try await fetch("/users")
    }

    func fetchUser(id: Int) async throws -> User {
        try await fetch("/users/\(id)")
    }

    // MARK: - Albums

    func fetchAlbums() async throws -> [Album] {
        try await fetch("/albums")
    }

    func fetchAlbum(id: Int) async throws -> Album {
        try await fetch("/albums/\(id)")
    }

    func fetchPhotos(forAlbum albumId: Int) async throws -> [Photo] {
        try await fetch("/albums/\(albumId)/photos")
    }
}
