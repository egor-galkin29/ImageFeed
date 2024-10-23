import ImageFeed
import UIKit

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var isViewDidLoadCalled = false
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func getProfile() -> ImageFeed.Profile? { return nil }
    
    func getAvatarURL() -> URL? { return nil }
}
