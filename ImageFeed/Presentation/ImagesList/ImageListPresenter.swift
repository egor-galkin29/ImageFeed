import Foundation

public protocol ImageListPresenterProtocol: AnyObject {
    var view: ImageListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidload()
    func updateTableViewAnimated()
}

final class ImageListPresenter: ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol?
    var imageListService = ImagesListService.shared
    var photos: [Photo] = []
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
}
