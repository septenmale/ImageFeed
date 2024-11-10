import Foundation

final class ProfileImageService {
    
    enum ProfileImageServiceError: Error {
        case invalidRequest
    }
    
    static let shared = ProfileImageService()
    
    private init() {}
    
    private(set) var avatarURL: String?
    
    private var lastTask: URLSessionTask?
    private var lastToken: String?
    
    private func userProfileImageRequest(token: String) -> URLRequest? {
        
        let baseURLString = "https://api.unsplash.com"
        guard let userName = ProfileService.shared.profile?.userName else {
            print("Error: User name not found in profile")
            return nil
        }
        
        guard let url = URL(string: "\(baseURLString)/users/\(userName)") else {
            print("Error: Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("ProfileImage request URL: \(url.absoluteString)")
        print("HTTP method: \(request.httpMethod ?? "nil")")
        
        guard let authHeader = request.value(forHTTPHeaderField: "Authorization") else {
            print("Error: Failed to get Authorization header")
            return nil
        }
        print("Authorization header: \(authHeader)")
        
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        
        guard let token = OAuth2TokenStorage.shared.token else { // достаем токен
            print("Error: No token found in ProfileImageService")
            completion(.failure(NetworkError.tokenError))
            return
        }
        
        guard lastToken != token else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        lastTask?.cancel()
        lastToken = token
        
        guard let request = userProfileImageRequest(token: token) else {
            print("Error: Failed to request for token \(token)")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            DispatchQueue.main.async {
                
                self.lastTask = nil
                self.lastToken = nil
                
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(UserResult.self, from: data)
                        self.avatarURL = response.profileImageSmallURL.absoluteString
                        completion(.success(response.profileImageSmallURL.absoluteString))
                    } catch {
                        print("Error while decoding userImage: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    print("Network error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
            
            self.lastToken = token
        task.resume()
    }
    
}
