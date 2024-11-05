
struct Profile { // вынес отдельно так как это модель данных, предназначенная для UI-слоя, а ProfileService - ceть
    let userName: String
    let name: String
    let loginName: String
    let bio: String
    
    init(from profileResult: ProfileResult) {
        self.userName = profileResult.userName
        self.name = "\(profileResult.firstName) \(profileResult.lastName)"
        self.loginName = "@\(profileResult.userName)"
        self.bio = profileResult.bio
    }
    
}

final class ProfileService {
    
}
