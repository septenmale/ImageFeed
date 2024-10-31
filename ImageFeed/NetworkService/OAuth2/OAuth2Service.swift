import UIKit
import WebKit

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
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
        
        var reguest = URLRequest(url: url)
        reguest.httpMethod = "POST"
        
        print("Auth reguest URL: \(url.absoluteString)")
        print("HTTP Method: \(reguest.httpMethod ?? "nil")")
        return reguest
    }
    
    func fetchOAuthToken(with code: String, handler: @escaping (Result<String, Error>) -> Void) {
        guard let request = authTokenRequest(code: code) else {
            handler(.failure(NetworkError.urlSessionError))
            print("Error: Failed to create an authorization request for code \(code)")
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
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
        task.resume()
    }
    
}
