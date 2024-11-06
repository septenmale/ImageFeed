import UIKit
import WebKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession: URLSession = URLSession.shared
    
    private var lastTask: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    private func authTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Error: Failed to create urlComponents. Check base url + Path.")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print("Error: Failed to create URL from the provided URl components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        print("Auth request URL: \(url.absoluteString)")
        print("HTTP Method: \(request.httpMethod ?? "nil")")
        return request
    }
    
    func fetchOAuthToken(with code: String, handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread) // проверяем что код вып-ся из гл-го потока
        guard lastCode != code else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
//        if lastTask != nil { // пр-м вып-ся ли щас пост запрос
//            if lastCode != code { // пр-м что в запросе который щас в процессе такое же как в аргументе
//                lastTask?.cancel() // отменяем запрос: code не актуальный
//            } else {
//                handler(.failure(AuthServiceError.invalidRequest))
//                return
//            }
//        } else {
//            if lastCode == code { // запросов нет, но токен для данного code получен
//                handler(.failure(AuthServiceError.invalidRequest))
//                return
//            }
//        }
        lastTask?.cancel() // если решусь вернуться - удалить
        lastCode = code
        
        
        guard let request = authTokenRequest(code: code) else { // Создаём запрос на получение Auth Token c даным кодом
            print("Error: Failed to create an authorization request for code \(code)")
            handler(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            DispatchQueue.main.async {
                
                self.lastTask = nil
                self.lastCode = nil
                
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        handler(.success(response.accessToken))
                        
                        OAuth2TokenStorage.shared.token = response.accessToken
                    } catch {
                        print("Error while decoding: \(error.localizedDescription)")
                        handler(.failure(error))
                    }
                    
                case . failure(let error):
                    print("Network error: \(error.localizedDescription)")
                    handler(.failure(error))
                }
            }
        }
        self.lastTask = task
        task.resume()
    }
    
}
