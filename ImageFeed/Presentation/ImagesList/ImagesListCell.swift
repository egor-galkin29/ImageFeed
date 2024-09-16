import UIKit

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLable: UILabel!
    
    func configure(cell: ImagesListCell, image: UIImage, text: String, likeImageName: String) {
        cellImage.image = image
        dateLable.text = text
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
    
    override func prepareForReuse() {
            super.prepareForReuse()
            cellImage.kf.cancelDownloadTask()
            cellImage.image = nil
            dateLable.text = nil
        }
}

