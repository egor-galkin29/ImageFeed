import Foundation
import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    let oauth2Service = OAuth2Service.shared
    let profileImageService = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchPofile(token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchPofile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profile):
                guard let username = self.profileService.profile?.username else { return }
                self.profileImageService.fetchProfileImageURL(username: username) {_ in }
                self.switchToTabBarController()
            case .failure(let failure):
                print("ERROR: did not get profile")
                break
            }
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
            return
        }
        
        fetchPofile(token)
    }
}
