import UIKit

final class AuthViewController: UIViewController, WebViewViewContrrollerDelegate {
    private let showWebViewSequeIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSequeIdentifier {
            if let viewController = segue.destination as? WebViewViewController {
               viewController.delegate = self
            }
        }
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        <#code#>
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        <#code#>
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")?.withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")?.withRenderingMode(.alwaysOriginal)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
}
