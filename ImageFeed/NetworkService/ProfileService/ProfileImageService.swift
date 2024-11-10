
final class ProfileImageService {
    
    private func userProfileImageRequest(token: String) -> URLRequest? {
        
        let baseURLString = "https://api.unsplash.com"
        
        guard let url = URL(string: "\(baseURLString)/users/:\(profile.userName)" else {
            print("Error: Failed to create urlComponents. Check url")
            return nil
        }
                            
    }
    
                            
}
