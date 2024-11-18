import UIKit
import ProgressHUD

class SplashViewController: UIViewController {

//    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    func navigateToAuthenticationScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController {
                    
                    // Настройка делегата (если нужно)
                    authViewController.delegate = self
                    
                    // Установка стиля презентации на полноэкранный
                    authViewController.modalPresentationStyle = .fullScreen
                    
                    // Презентация AuthViewController
                    present(authViewController, animated: true, completion: nil)
                }
    }
    
    func showAuthScreen() {
        navigateToAuthenticationScreen()
        }
    
    private let splashLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vector")
        return imageView
    }()
    
    private func setupConstraints() {
        splashLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashLogo)
        
        splashLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        splashLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token)
        } else {
            navigateToAuthenticationScreen()
//            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OAuth2TokenStorage.shared.token = nil
        
        setupConstraints()
        view.backgroundColor = .ypBlackIOS
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

//extension SplashViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == showAuthenticationScreenSegueIdentifier {
//            
//            guard
//                let navigationController = segue.destination as? UINavigationController,
//                let viewController = navigationController.viewControllers[0] as? AuthViewController
//            else {
//                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
//                return
//            }
//            
//            viewController.delegate = self
//            
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
//}

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
//        switchToTabBarController() это должно произойдет по завершению fetchProfile
        
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
            case .success(let profile): // Профиль загружен успешно, теперь можно получить аватар пользователя
                // Вызываем fetchProfileImageURL для загрузки аватара асинхронно
                profileImageService.fetchProfileImageURL(username: profile.userName) { _ in }
                print("Profile image loading")
                // Переход к следующему экрану (галерее) без ожидания завершения загрузки аватара
                self.switchToTabBarController()
                
            case .failure(let error):
                print("Failed to fetch profile: \(error.localizedDescription)")
                break
            }
        }
    }
    
}


