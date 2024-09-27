import Foundation
import UIKit

// MARK: - SplashViewController

final class SplashViewController: UIViewController {
    
// MARK: - Private Properties

    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
// MARK: - Public Properties

    let oauth2Service = OAuth2Service.shared
    let profileImageService = ProfileImageService.shared
    
// MARK: - Public Methods

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchPofile(token)
        } else {
            print("ERROR: the tokeen was not found")
        }
        setUpSplashScreen()
        showAuthViewController()
    }
    
// MARK: - Private Methods

    // MARK: - switchToTabBarController

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    // MARK: - setUpSplashScreen

    private func setUpSplashScreen() {
        let splashImageView = UIImageView()
        splashImageView.translatesAutoresizingMaskIntoConstraints = false
        splashImageView.image = UIImage(named: "lounch_screen_logo")
        splashImageView.backgroundColor = UIColor.ypBlack
        view.addSubview(splashImageView)
        splashImageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        splashImageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK: - showAuthViewController

    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            print("ERROR: with AuthViewController")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        
        present(authViewController, animated: true, completion: nil)
    }
    
    // MARK: - fetchPofile

    private func fetchPofile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profile):
                self.profileImageService.fetchProfileImageURL(username: profile.username) {_ in }
                self.switchToTabBarController()
                print("success")
            case .failure(let error):
                print("\(error)")
                break
            }
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
            return
        }
        
        fetchPofile(token)
    }
}
