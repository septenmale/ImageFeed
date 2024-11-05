struct ProfileResult: Decodable { // в примере предлагают codable, додумался изменить на Decodable
    let userName: String
    let firstName: String
    let lastName: String
    let bio: String
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
    
}
