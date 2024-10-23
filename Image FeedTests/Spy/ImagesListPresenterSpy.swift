@testable import ImageFeed
import UIKit

final class ImagesListPresenterSpy: ImageListPresenterProtocol {
    var imagesListService = ImagesListService.shared
    var view: ImageListViewControllerProtocol?
    var photos: [Photo] = []
    var stubPhotos: [PhotoConfiguration] = []
    var isViewDidLoadCall: Bool = false
    
    func viewDidload() { isViewDidLoadCall = true }
    
    func getCellHeight(_ tableViewBoundsWidth: CGFloat, _ photoIndex: Int) -> CGFloat { return 0 }
    
    func loadImages() {}
    
    func updateTableViewAnimated() {}
}
