import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        //nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor) перенес зеркально в профайлИмэдж
        //nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8) перенес зеркально в профайлИмэдж
        
        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.textColor = .white
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        
//        let profileImage = UIImage(systemName: "Photo")
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(named: "Photo")
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        // constraints
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -8).isActive = true // тут не уверен переносил зеркально плюс поменял на минус
        
//        let logoutButtonImage = UIImage(systemName: "Exit")
        let logoutButton = UIButton(type: .system)
        logoutButton.setImage(UIImage(named: "Exit")?.withRenderingMode(.alwaysOriginal), for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    }
    
    
}
