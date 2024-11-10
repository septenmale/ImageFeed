import UIKit
import ProgressHUD

class SplashViewController: UIViewController {

    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    private let profileService = ProfileService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
        
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

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

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
                ProfileImageService.shared.fetchProfileImageURL(username: profile.userName) { _ in }
                // Переход к следующему экрану (галерее) без ожидания завершения загрузки аватара
                self.switchToTabBarController()
                
            case .failure(let error):
                print("Failed to fetch profile: \(error.localizedDescription)")
                break
            }
        }
    }
    
}


// Закончил ProfileImageService. Проблемы могут быть с устранением гонок и вызовом fetchProfileImageURL в SplashViewController
