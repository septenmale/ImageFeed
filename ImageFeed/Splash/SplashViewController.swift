import UIKit
import ProgressHUD

class SplashViewController: UIViewController {

    // MARK: - Private Properties
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private let splashLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vector")
        return imageView
    }()
    
    // MARK: - Overrides Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token)
        } else {
            navigateToAuthenticationScreen()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupConstraints()
        view.backgroundColor = .ypBlackIOS
    }
    
    // MARK: - Private Methods
    private func navigateToAuthenticationScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController {
            
            authViewController.delegate = self
            
            authViewController.modalPresentationStyle = .fullScreen
            
            present(authViewController, animated: true, completion: nil)
        }
    }
    
    private func setupConstraints() {
        splashLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashLogo)
        
        splashLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        splashLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    private func switchToTabBarController() {
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Error: no auth token found")
            return
        }
        
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHud.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHud.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                profileImageService.fetchProfileImageURL(username: profile.userName) { _ in }
                print("Profile image loading")
                
                self.switchToTabBarController()
                
            case .failure(let error):
                print("Failed to fetch profile: \(error.localizedDescription)")
                break
            }
        }
    }
    
}


