import Foundation

public protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func getProfile() -> Profile?
    func getAvatarURL() -> URL?
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        view?.setupView()
        view?.setupConstraints()
    }
    
    public func getProfile() -> Profile? {
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
