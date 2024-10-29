import UIKit
import WebKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private enum NetworkError: Error {
        case codeError
        case dataError
        case tokenParsingError
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
            print("Error: Failed to create URL from the provided URl components") // Debug output
            return nil
        }
        
        var reguest = URLRequest(url: url)
        reguest.httpMethod = "POST"
        
        // Debug output: print the reguest
        print("Auth reguest URL: \(url.absoluteString)")
        print("HTTP Method: \(reguest.httpMethod ?? "nil")")
        return reguest
    }
    
    func fetchOAuthToken(with code: String, handler: @escaping (Result<String, Error>) -> Void) {
        guard let request = authTokenRequest(code: code) else { // создаем URLRequest
            handler(.failure(NetworkError.dataError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in // выполняет сетевой запрос и получает ответ
            if let error = error {                                                      // от сервера
                handler(.failure(error))                                                // если произошла ошибка - возвразаем в замыкание
                return
            }
            
            if let response = response as? HTTPURLResponse,                 // проверяем что ответ содержит код 200-299
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else {                                    // проверяем что данные не пусты
                handler(.failure(NetworkError.dataError))
                return
            }
            
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], // парсим ответ чтобы извлечь acces_token
//                   let accesToken = json["acess_token"] as? String {
//                    handler(.success(accesToken))
//                } else {
//                    handler(.failure(NetworkError.tokenParsingError))                         // если не удалось найти возвращаем ошибку
//                }
//            } catch {
//                handler(.failure(error))
//            }
        }
        task.resume()
    }
    
}
