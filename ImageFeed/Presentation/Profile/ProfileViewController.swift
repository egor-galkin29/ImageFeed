import UIKit

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {
    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addProfileImage()
        addLables()
        addEscapeButton()
    }
    
    private func addProfileImage() {
        let profileImage = UIImage(named: "avatarPhoto")
        imageView.image = profileImage
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func addLables() {
        // constants
        let nameLable = UILabel()
        let nickNameLable = UILabel()
        let statusLable = UILabel()
        
        // text
        nameLable.text = "Егор Галкин"
        nickNameLable.text = "@shashluck_ketchup"
        statusLable.text = "Hello, World!"
        
        // nameLable settings
        nameLable.textColor = .white
        nameLable.font = UIFont.boldSystemFont(ofSize: 23)
        
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLable)
        
        // nickNameLable settings
        nickNameLable.textColor = .lightGray
        nickNameLable.font = UIFont.systemFont(ofSize: 13)
        
        nickNameLable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nickNameLable)
        
        // statusLable settings
        statusLable.textColor = .white
        statusLable.font = UIFont.systemFont(ofSize: 13)
        
        statusLable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLable)
        
        NSLayoutConstraint.activate([
            nameLable.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLable.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 24),
            
            nickNameLable.topAnchor.constraint(equalTo: nameLable.bottomAnchor, constant: 8),
            nickNameLable.leadingAnchor.constraint(equalTo: nameLable.leadingAnchor),
            
            statusLable.topAnchor.constraint(equalTo: nickNameLable.bottomAnchor, constant: 8),
            statusLable.leadingAnchor.constraint(equalTo: nameLable.leadingAnchor)
        ])
    }
    
    private func addEscapeButton() {
        let button = UIButton.systemButton(
                    with: UIImage(named: "log out")!,
                    target: nil,
                    action: nil
                )
        button.tintColor = .ypRed
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
}
