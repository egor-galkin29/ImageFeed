import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    func setupView() {}
    
    func setupConstraints() {}
    
    func updateAvatar() { }
    
    func configure(_ presenter: ProfilePresenterProtocol) { }
}
