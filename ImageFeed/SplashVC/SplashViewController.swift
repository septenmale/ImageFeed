import UIKit

class SplashViewController: UIViewController {
//    private let storage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = OAuth2TokenStorage.shared.token {
            // show tapBarController
            // TODO:
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
        
    }
    
}
