import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            print("Segue identifier is correct")
            guard let webViewViewController = segue.destination as? WebViewViewController
            else {
                print("Failed to cast segue destination to WebViewViewController")
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            print("Successfully cast to WebViewViewController")
            let webViewPresenter = WebViewPresenter()
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
            print("Presenter and delegate set successfully")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Public Methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")?.withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")?.withRenderingMode(.alwaysOriginal)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("Received authorization code: \(code)")
        vc.dismiss(animated: true)
        
        UIBlockingProgressHud.show()
        OAuth2Service.shared.fetchOAuthToken(with: code) { result in
            
            UIBlockingProgressHud.dismiss()
            switch result {
                
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                print("Token received and saved: \(token)")
                self.dismiss(animated: true)
                
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                print("[AuthViewController]: Error: token did not received: \(error.localizedDescription)")
                
                let alert = UIAlertController(title: "Что-то пошло не так(",
                                              message: "Не удалось войти в систему",
                                              preferredStyle: .alert
                )
                
                let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
                
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
}
