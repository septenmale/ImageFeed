import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAuthView()
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthoriseURLString) else {
            print("Error: Failed to create urlComponents. Check unsplashAuthoriseURLString.")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Error: Failed to create URL from the provided URl components")
            return
        }
        
        let reguest = URLRequest(url: url)
        webView.load(reguest)
    }
    
    enum WebViewConstants {
        static let unsplashAuthoriseURLString = "https://unsplash.com/oauth/authorize"
    }
}
