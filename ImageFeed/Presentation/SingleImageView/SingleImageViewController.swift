import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var largeImageURL: URL?
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

private extension SingleImageViewController {
    func loadImage() {
        guard let largeImageURL = largeImageURL else { return }
        let kf = KingfisherManager.shared
        imageView.image = UIImage(named: "Stub")
        UIBlockingProgressHUD.show()
        kf.retrieveImage(with: largeImageURL) {result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let value):
                self.image = value.image
                print("Изображение успешно загружено: \(value.image)")
            case .failure(let error):
                print("Ошибка загрузки: \(error.localizedDescription)")
                self.showError(vc: self)
            }
        }
    }
    
    // MARK: - Error Alert
    func showError(vc: SingleImageViewController) {
        let alert = UIAlertController(
            title: "Что-то пошло не так!",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert)
        
        let cancelButton = UIAlertAction(title: "Не надо", style: .cancel, handler: nil)
        let retryAction = UIAlertAction(title: "Повторить", style: .cancel) { _ in
            self.loadImage()
        }
        
        alert.addAction(cancelButton)
        alert.addAction(retryAction)
        
        self.present(vc, animated: true, completion: nil)
    }
}
