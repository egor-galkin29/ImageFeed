import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateAvatar()
    func setupView()
    func setupConstraints()
    func configure(_ presenter: ProfilePresenterProtocol)
}

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol{
    
    var presenter: ProfilePresenterProtocol?
    // MARK: - Private Properties
    
    private let profileService = ProfileService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    private let imageViewGradient = CAGradientLayer()
    private let nameLabelGradient = CAGradientLayer()
    private let nickNameLabelGradient = CAGradientLayer()
    private let statusLableGradient = CAGradientLayer()
    private var gradientLayers: [CAGradientLayer] = []
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    //MARK: - UI Components
    
    private let imageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "avatarPhoto"))
        image.layer.cornerRadius = 35
        image.layer.masksToBounds = true
        return image
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "log out"), for: .normal)
        button.tintColor = .ypRed
        button.accessibilityIdentifier = "logout button"
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private let statusLable: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    // MARK: - Public Methods
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        createGradients()
        updateAvatar()
        
        presenter?.viewDidLoad()
        
        guard let profile = presenter?.getProfile() else {
            print("профайла нет")
            return }
        
        updateLableText(profile)
    }
    
    // MARK: - viewDidLayoutSubviews
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateAllGradients()
    }
    
    // MARK: - updateLableText
    
    func updateLableText(_ profile: Profile) {
        nameLabel.text = profile.name
        nickNameLabel.text = profile.loginName
        statusLable.text = profile.bio
    }
    
    // MARK: - removeGradients
    
    func removeGradients() {
        for gradient in gradientLayers {
            gradient.removeFromSuperlayer()
        }
        gradientLayers.removeAll()
    }
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    // MARK: - showLogoutAlert
    
    func showLogoutAlert(vc: ProfileViewController) {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверенные что хотите выйти?",
            buttons: [.yesButton, .noButton],
            identifier: "Logout",
            completion: {
                self.profileLogoutService.logout()
            }
        )
        AlertPresenter.showAlert(on: vc, model: alertModel)
    }
    
    // MARK: - didTapLogoutButton
    
    @objc func didTapLogoutButton() {
        dismiss(animated: true)
        showLogoutAlert(vc: self)
    }
    
    // MARK: - Private Methods
    
    func updateAvatar() {
        let url = presenter?.getAvatarURL()
        imageView.kf.setImage(with: url)
        
        removeGradients()
    }
    
    // MARK: - setupView
    
    func setupView() {
        view.backgroundColor = .ypBlack
        
        [imageView, logoutButton, nameLabel, nickNameLabel, statusLable].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    // MARK: - setupConstraints
    
    func setupConstraints() {
        setupUserImageConstraints()
        setupLogoutButtonConstraints()
        setupUserNameLabelConstraints()
        setupUserLoginLabelConstraints()
        setupUserDescriptionLabelConstraints()
    }
    
    // MARK: - setupLogoutButtonConstraints
    
    private func setupUserImageConstraints() {
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76)
        ])
    }
    
    // MARK: - setupLogoutButtonConstraints
    
    private func setupLogoutButtonConstraints() {
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
    
    // MARK: - setupUserNameLabelConstraints
    
    private func setupUserNameLabelConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
    }
    
    // MARK: - setupUserLoginLabelConstraints
    
    private func setupUserLoginLabelConstraints() {
        NSLayoutConstraint.activate([
            nickNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nickNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    // MARK: - setupUserDescriptionLabelConstraints
    
    private func setupUserDescriptionLabelConstraints() {
        NSLayoutConstraint.activate([
            statusLable.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor),
            statusLable.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    // MARK: - addGradient
    
    private func addGradient(to view: UIView) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 0.1, 0.3]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = view.bounds
        
        if let lable = view as? UILabel {
            gradientLayer.cornerRadius = 7
        } else {
            gradientLayer.cornerRadius = 35
        }
        
        gradientLayer.masksToBounds = true
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientLayer.add(gradientChangeAnimation, forKey: "locationsChange")
        
        return gradientLayer
    }
    
    // MARK: - updateGradientLayerFrame
    
    private func updateGradientLayerFrame(for view: UIView) {
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
    }
    
    // MARK: - createGradients
    
    private func createGradients() {
        let gradient1 = addGradient(to: nameLabel)
        let gradient2 = addGradient(to: nickNameLabel)
        let gradient3 = addGradient(to: statusLable)
        let gradient4 = addGradient(to: imageView)
        
        gradientLayers.append(contentsOf: [gradient1, gradient2, gradient3, gradient4])
    }
    
    // MARK: - updateAllGradients
    
    private func updateAllGradients() {
        updateGradientLayerFrame(for: nameLabel)
        updateGradientLayerFrame(for: nickNameLabel)
        updateGradientLayerFrame(for: statusLable)
        updateGradientLayerFrame(for: imageView)
    }
}
