import UIKit

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
    
    override func viewDidLoad() {
            super.viewDidLoad()
        guard let token = tokenStorage.token else {
            return
        }
        
        guard let profile = profileService.profile else {
                   print("No profile found")
                   return
               }
        
        profileService.fetchProfile(token) {_ in
            self.nameLabel.text = profile.name
            self.nickNameLabel.text = profile.loginName
            self.statusLable.text = profile.bio
        }
        
            setup()
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
