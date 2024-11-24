import WebKit

struct Profile { 
    let userName: String
    let name: String
    let loginName: String
    let bio: String
    
    init(from profileResult: ProfileResultResponseBody) {
        self.userName = profileResult.userName
        self.name = "\(profileResult.firstName) \(profileResult.lastName ?? "")"
        self.loginName = "@\(profileResult.userName)"
        self.bio = profileResult.bio ?? "No bio available"
    }
    
}

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    
    static let shared = ProfileService()
    
    private init() {}
    
    private(set) var profile: Profile?
    
    private var lastTask: URLSessionTask?
    private var lastToken: String?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastToken != token else {
            completion( .failure(ProfileServiceError.invalidRequest))
            return
        }
        
        lastTask?.cancel()
        lastToken = token
        
        guard let request = userPublicProfileRequest(token: token) else {
            print("[ProfileService]: Error: Failed to request for token \(token)")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let urlSession = URLSession.shared
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResultResponseBody, Error>) in
            DispatchQueue.main.async {
                
                self?.lastTask = nil
                self?.lastToken = nil
                
                switch result {
                case .success(let response):
                    let profile = Profile(from: response)
                    self?.profile = profile
                    completion( .success(profile))
                    
                case .failure(let error):
                    print("[ProfileService]: Error while fetching profile: \(error.localizedDescription)")
                    completion( .failure(error))
                }
            }
        }
        
        self.lastToken = token
        task.resume()
    }
    
    private func userPublicProfileRequest(token: String) -> URLRequest? {
        let unsplashBaseURLString = "https://api.unsplash.com"
        
        guard let url = URL(string: "\(unsplashBaseURLString)/me") else {
            print("Error: Failed to create urlComponents.Check unsplashBaseURLString")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("Profile request URL: \(url.absoluteString)")
        print("HTTP method: \(request.httpMethod ?? "nil")")
        guard let authHeader = request.value(forHTTPHeaderField: "Authorization") else {
            print("Error: Failed to get Authorization header.")
            return nil
        }
        print("Authorization header: \(authHeader)")
        
        return request
    }
    
}
