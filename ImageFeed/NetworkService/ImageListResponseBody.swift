import Foundation

struct PhotoResultResponseBody: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case width = "width"
        case height = "height"
        case description = "description"
        case likedByUser = "liked_by_user"
        case urls = "urls"
    }
    
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}
