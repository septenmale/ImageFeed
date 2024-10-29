import UIKit

final class AuthViewController: UIViewController, WebViewViewContrrollerDelegate {
    private let showWebViewSequeIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSequeIdentifier {
            guard
                let viewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSequeIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    } // было по другому переделал как в решении
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("Received authorization code: \(code)")
        
        OAuth2Service.shared.fetchOAuthToken(with: code) { result in
            switch result {
                
            case .success(let token):
                OAuth2TokenStorage.shared.token = token // ??
                print("Token received and saved: \(token)")
                self.dismiss(animated: true)
                
            case .failure(let error):
                print("Error: token did not received: \(error.localizedDescription)")
            }
        }

    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
         vc.dismiss(animated: true)
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")?.withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")?.withRenderingMode(.alwaysOriginal)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
}
