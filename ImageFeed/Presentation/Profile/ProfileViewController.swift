import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    private let imageView: UIImageView = {
            let image = UIImageView(image: UIImage(named: "avatarPhoto"))
            image.layer.cornerRadius = 35
            return image
        }()
        
        private let escapeButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "log out"), for: .normal)
            button.tintColor = .ypRed
            return button
        }()
        
        private let nameLabel: UILabel = {
            let label = UILabel()
            label.text = "Егор Галкин"
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
            return label
        }()
        
        private let nickNameLabel: UILabel = {
            let label = UILabel()
            label.text = "@shashluck_ketchup"
            label.textColor = .lightGray
            label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            return label
        }()
    
    private let statusLable: UILabel = {
            let label = UILabel()
            label.text = "Hello, world!"
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            return label
        }()
    
    override init(nibName: String?, bundle: Bundle?) {
            super.init(nibName: nibName, bundle: bundle)
            addObserver()
        }
    
    required init?(coder: NSCoder) {
            super.init(coder: coder)
            addObserver()
        }
    
    deinit {
            removeObserver()
        }
    
    private func addObserver() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateAvatar(notification:)),
                name: ProfileImageService.didChangeNotification,
                object: nil)
        }
       
       private func removeObserver() {
            NotificationCenter.default.removeObserver(
                self,
                name: ProfileImageService.didChangeNotification,
                object: nil)
        }
       
        @objc
        private func updateAvatar(notification: Notification) {
            guard
                isViewLoaded,
                let userInfo = notification.userInfo,
                let profileImageURL = userInfo["URL"] as? String,
                let url = URL(string: profileImageURL)
            else { return }
            
            imageView.kf.setImage(with: url) { result in
                    switch result {
                    case .success(let value):
                        print("Image: \(value.image); Image URL: \(value.source.url?.absoluteString ?? "")")
                    case .failure(let error):
                        print("Error: \(error)")
                }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let avatarURL = ProfileImageService.shared.avatarURL,
           let url = URL(string: avatarURL) {
            // TODO [Sprint 11]  Обновите аватар, если нотификация
            
            updateLableText()
            setup()
        }
    }
    
    func updateLableText() {
        if let profile = profileService.profile {
            nameLabel.text = profile.name
            nickNameLabel.text = profile.loginName
            statusLable.text = profile.bio
        } else {
            print("profile was not found")
        }
    }
        
        private func setup() {
            setupView()
            setupConstraints()
        }
    
    private func setupView() {
            view.backgroundColor = .ypBlack
            
            [imageView, escapeButton, nameLabel, nickNameLabel, statusLable].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }
        }
        
    private func setupConstraints() {
            setupUserImageConstraints()
            setupLogoutButtonConstraints()
            setupUserNameLabelConstraints()
            setupUserLoginLabelConstraints()
            setupUserDescriptionLabelConstraints()
        }
        
    private func setupActions() {
            escapeButton.addTarget(self, action: #selector(self.didTapLogoutButton), for: .touchUpInside)
        }
    
    private func setupUserImageConstraints() {
            NSLayoutConstraint.activate([
                imageView.heightAnchor.constraint(equalToConstant: 70),
                imageView.widthAnchor.constraint(equalToConstant: 70),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76)
            ])
        }
        
    private func setupLogoutButtonConstraints() {
            NSLayoutConstraint.activate([
                escapeButton.heightAnchor.constraint(equalToConstant: 44),
                escapeButton.widthAnchor.constraint(equalToConstant: 44),
                escapeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                escapeButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
        }
        
    private func setupUserNameLabelConstraints() {
            NSLayoutConstraint.activate([
                nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
            ])
        }
        
    private func setupUserLoginLabelConstraints() {
            NSLayoutConstraint.activate([
                nickNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
                nickNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
            ])
        }
        
    private func setupUserDescriptionLabelConstraints() {
            NSLayoutConstraint.activate([
                statusLable.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor),
                statusLable.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8)
            ])
        }
    @objc private func didTapLogoutButton() {}
}
