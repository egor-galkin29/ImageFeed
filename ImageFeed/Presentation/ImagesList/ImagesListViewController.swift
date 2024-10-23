import UIKit
import Kingfisher

public protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListPresenterProtocol? { get set }
    func updateTableViewAnimated(_ indexPaths: [IndexPath])
    func loadImages()
}
// MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController & ImageListViewControllerProtocol {
    
    // MARK: - IBOutlet
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Public Properties
    
    var presenter: ImageListPresenterProtocol?
    
    // MARK: - Private Properties
    
    private let imagesListCell = ImagesListCell()
    private let dateFormatter = DateConvertor.shared
    private let imagesListService = ImagesListService.shared
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private var photos: [Photo] = []
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        if photos.count == 0 {
            presenter?.loadImages()
        }
        presenter?.viewDidload()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            viewController.photo = presenter?.photos[indexPath.row]
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    
    func loadImages() {
        self.tableView.reloadData()
    }
    
    func updateTableViewAnimated(_ indexPaths: [IndexPath]) {
        self.tableView.performBatchUpdates {
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func configure(_ presenter: ImageListPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
}

// MARK: - ImagesListViewController

extension ImagesListViewController {
    
    // MARK: - configCell
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let photo = presenter?.photos[safeIndex: indexPath.row] else { return }
        
        let stringDate: String
        
        if let date = photo.createdAt {
            stringDate = dateFormatter.getStringFromDate(from: date)
        } else {
            stringDate = ""
        }
        
        let imageURLString = photo.thumbImageURL
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: imageURLString),
            placeholder: nil,
            options: [.transition(.fade(1))]) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let value):
                    cell.configure(image: value.image, text: stringDate, isLiked: photo.isLiked)
                    
                case .failure(let error):
                    guard let placeholder = UIImage(named: "Stub") else {return}
                    cell.gradientLayer?.isHidden = false
                    cell.configure(
                        image: placeholder,
                        text: stringDate,
                        isLiked: photo.isLiked
                    )
                }
                
            }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    // MARK: - tableView(numberOfRowsInSection)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photos.count ?? 0
    }
    
    // MARK: - tableView(cellForRowAt)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell {
            cell.delegate = self
            
            configCell(for: cell, with: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    // MARK: - tableView(willDisplay)
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let imagesCount = photos.count
        
        if indexPath.row == (imagesCount - 1) {
            presenter?.loadImages()
        }
    }
    
    // MARK: - tableView(didSelectRowAt)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    // MARK: - tableView(heightForRowAt)
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter?.getCellHeight(tableView.bounds.width, indexPath.row) ?? 0
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    
    // MARK: - imageListCellDidTapLike
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = imagesListService.photos[indexPath.row]
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                }
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("DEBUG",
                      "[\(String(describing: self)).\(#function)]:",
                      error.localizedDescription,
                      separator: "\n")
            }
        }
    }
}
