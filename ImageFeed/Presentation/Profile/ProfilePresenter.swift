import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func getProfile() -> Profile?
    func getAvatarURL() -> URL?
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    func getProfile() -> Profile? {
        guard let profile = ProfileService.shared.profile else { return nil }
        return profile
    }
    
    func getAvatarURL() -> URL? {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return nil}
        
        return url
    }
}
