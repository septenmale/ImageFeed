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
            // Создаем контейнер верхнего уровня для всех ключей в JSON-объекте
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // Создаем вложенный контейнер для profile_image, чтобы добраться до ключа "small"
            let profileImageContainer = try container.nestedContainer(keyedBy: ProfileImageKeys.self, forKey: .profileImage)
            // Извлекаем URL для ключа "small" из вложенного контейнера и присваиваем его свойству `profileImageSmallURL
            profileImageSmallURL = try profileImageContainer.decode(URL.self, forKey: .small)
        } catch {
            print("Error while decoding UserResult: \(error.localizedDescription)")
            throw error
        }
    }
    
}
