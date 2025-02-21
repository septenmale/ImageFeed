import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateProfileDetails(profile: Profile)
    func updateAvatar()
    func showBackButtonAlert()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    var presenter: ProfileViewPresenterProtocol?
    
    private let profileService = ProfileService.shared
    
    func configure(_ presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Ekaterina Novikova"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGrayIOS
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Photo")
        return imageView
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Exit")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        button.accessibilityIdentifier = "logoutButton"
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        view.backgroundColor = .ypBlackIOS
        
        presenter?.viewDidLoad()
        updateAvatar()
    }
    
    func cleanProfileData() {
        nameLabel.text = nil
        loginNameLabel.text = nil
        descriptionLabel.text = nil
        profileImageView.image = nil
    }
    
    @objc func didTapBackButton() {
        presenter?.didTapBackButton()
    }
   
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        profileImageView.kf.setImage(with: url,
                                     placeholder: UIImage(named: "placeholder"),
                                     options: [.processor(processor)
                                              ]) { result in
            switch result{
            case .success(let value):
                print("Photo: \(value.image)")
                print("Photo cache type: \(value.cacheType)")
                print("Photo source: \(value.source)")
                
            case .failure(let error):
                print("[ProfileViewController]: Error while loading profileImage \(error.localizedDescription)")
            }
        }
        
    }
    
    func showBackButtonAlert() {
        let alert = UIAlertController(title: "By, By!" ,
                                      message: "Do you want to logout?",
                                      preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            ProfileLogoutService.shared.logout()
            guard let window = UIApplication.shared.windows.first else { return }
            window.rootViewController = SplashViewController()
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true)
    }
    
    func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func setupConstraints() {
        [nameLabel, loginNameLabel, descriptionLabel, profileImageView, logoutButton].forEach { element in
            view.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -8),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
        ])
    }
    
}
