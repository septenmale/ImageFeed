import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    
    var delegate: WebViewViewContrrollerDelegate? // добавляю св-во делегата
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        loadAuthView()
    }
    
    enum WebViewConstants {
        static let unsplashAuthoriseURLString = "https://unsplash.com/oauth/authorize"
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
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            //TODO: process code
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
}
