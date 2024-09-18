import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLable: UILabel!
    
    weak var delegate: ImagesListCellDelegate?

    func configure(image: UIImage, text: String, isLiked: Bool) {
        let LikeButtonImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")

        cellImage.image = image
        dateLable.text = text
        likeButton.setImage(LikeButtonImage, for: .normal)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let LikeButtonImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")

        self.likeButton.setImage(LikeButtonImage, for: .normal)
        }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLable.text = nil
    }
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}

