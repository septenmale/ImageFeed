import WebKit

struct Profile { // вынес отдельно так как это модель данных, предназначенная для UI-слоя, а ProfileService - ceть
    let userName: String
    let name: String
    let loginName: String
    let bio: String
    
    init(from profileResult: ProfileResultResponseBody) {
        self.userName = profileResult.userName
        self.name = "\(profileResult.firstName) \(profileResult.lastName)"
        self.loginName = "@\(profileResult.userName)"
        self.bio = profileResult.bio
    }
    
}

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    
    private var lastTask: URLSessionTask?
    private var lastToken: String?
    
    private func userPublicProfileRequest(token: String) -> URLRequest? {
        
        let unsplashBaseURLString = "https://unsplash.com" // создаю базовый url
        
        guard let url = URL(string: "\(unsplashBaseURLString)/me") else {
            print("Error: Failed to create urlComponents.Check unsplashBaseURLString")
            return nil
        }
        
        var request = URLRequest(url: url) // cоздаю реквест Написать дальше тип запрос
        request.httpMethod = "GET"         // Написать дальше тип запрос
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // задаю header
        
        print("Profile request URL: \(url.absoluteString)")
        print("HTTP method: \(request.httpMethod ?? "nil")")
        guard let authHeader = request.value(forHTTPHeaderField: "Authorization") else {
            print("Error: Failed to get Authorization header.")
            return nil
        }
        print("Authorization header: \(authHeader)")
        
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastToken != token else {
            completion( .failure(ProfileServiceError.invalidRequest))
            return
        }
        
        lastTask?.cancel()
        lastToken = token
        
        guard let request = userPublicProfileRequest(token: token) else { // запрос на получение profile c данным token
            print("Error: Failed to a request for token \(token)")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            DispatchQueue.main.async {
                
                self.lastTask = nil // вызываю тут чтобы независимо от результата completion значение обнулится
                self.lastToken = nil
                
                switch result { // обработка результата
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(ProfileResultResponseBody.self, from: data)
                        let profile = Profile(from: response) // Преобразуем response в Profile и возвращаем
                        completion( .success(profile))        // через замыкание
                    } catch {
                        print("Error while decoding profile JSON: \(error.localizedDescription)")
                        completion( .failure(error))
                    }
                    
                case .failure(let error):
                    print("Network error: \(error.localizedDescription)")
                    completion( .failure(error))
                }
            }
        }
        
        self.lastToken = token
        task.resume()
    }
    
}

// сделал все задания, получил такую ошибку: Error while decoding profile JSON: The data couldn’t be read because it isn’t in the correct format.
