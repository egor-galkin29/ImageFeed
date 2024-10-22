import UIKit

// MARK: - TabBarController

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier:"ImagesListViewController") as! ImagesListViewController
        let imageListPresenter = ImageListPresenter()
        imagesListViewController.presenter = imageListPresenter
        imageListPresenter.view = imagesListViewController
        
        let profileViewController = ProfileViewController()
        profileViewController.configure(ProfilePresenter())
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
