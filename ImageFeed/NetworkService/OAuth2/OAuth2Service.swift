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
    
    func fetchOAuthToken(with code: String, handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        lastTask?.cancel()
        lastCode = code
        
        guard let request = authTokenRequest(code: code) else {
            print("[OAuthService]: Error while creating an request for code \(code)")
            handler(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                
                self?.lastTask = nil
                self?.lastCode = nil
                
                switch result {
                case .success(let response):
                    print("Token response: \(response.accessToken)")
                    handler(.success(response.accessToken))
                    
                case .failure(let error):
                    print("[OAuthService]: Failed to fetch token: \(error.localizedDescription)")
                    handler(.failure(error))
                }
            }
        }
        self.lastTask = task
        task.resume()
    }
    
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
    
}
