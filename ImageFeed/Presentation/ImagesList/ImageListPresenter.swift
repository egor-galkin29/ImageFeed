import Foundation
import UIKit

public protocol ImageListPresenterProtocol: AnyObject {
    var view: ImageListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    var stubPhotos: [PhotoConfiguration] { get }
    func viewDidload()
    func updateTableViewAnimated()
    func getCellHeight(_ tableViewBoundsWidth: CGFloat, _ photoIndex: Int) -> CGFloat
    func loadImages()
}

final class ImageListPresenter: ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol?
    var imageListService = ImagesListService.shared
    private let imagesListService = ImagesListService.shared
    var photos: [Photo] = []
    var stubPhotos: [PhotoConfiguration] = []
    private var imageListServiceObserver: NSObjectProtocol?
    
    func viewDidload() {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            
            self.updateTableViewAnimated()
        }
    }
    
    func updateTableViewAnimated() {
            let oldCount = self.photos.count
            let newCount = self.imageListService.photos.count
            if oldCount != newCount {
                self.photos = self.imageListService.photos
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                view?.updateTableViewAnimated(indexPaths)
            }
    }
    
    func getCellHeight(_ tableViewBoundsWidth: CGFloat, _ photoIndex: Int) -> CGFloat {
        let photo = photos[photoIndex]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewBoundsWidth - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func loadImages() {
        imagesListService.fetchPhotosNextPage(completion: { [weak self] error in
            if let error {
                print(error.localizedDescription)
            } else {
                self?.view?.loadImages()
                print("перезагрузка экрана")
            }
        })
    }
}
