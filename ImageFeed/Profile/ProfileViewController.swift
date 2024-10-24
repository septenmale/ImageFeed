import UIKit

final class ProfileViewController: UIViewController {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        return label
    }()
    
    private let loginNameLabel: UILabel = {  // не нашел как исправить замечание п.3 Цвет поменял как было в фигме на серый, но с отступами не понимаю что не так. Так как отступ между nameBottom и loginNameTop должен быть такой же самый как и для loginNameBottom и descriptionTop тоесть 8. Качал специально авторское решение для этого задание когда делали в начале в Storyboard и там так же.
        // Остальные замечания исправленны
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
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Exit")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
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
