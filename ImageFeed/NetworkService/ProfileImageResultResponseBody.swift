import Foundation

struct UserResult: Decodable {
    let profileImageSmallURL: URL
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
    
    enum ProfileImageKeys: String, CodingKey {
        case small = "small"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let profileImageContainer = try container.nestedContainer(keyedBy: ProfileImageKeys.self,
                                                                      forKey: .profileImage)
            profileImageSmallURL = try profileImageContainer.decode(URL.self, forKey: .small)
        } catch {
            print("Error while decoding UserResult: \(error.localizedDescription)")
            throw error
        }
    }
    
}
