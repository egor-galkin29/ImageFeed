import UIKit

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private var cellImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLable: UILabel!
    
    func configure(cell: ImagesListCell, image: UIImage, text: String, likeImageName: String) {
        cell.cellImage.image = image
        cell.dateLable.text = text
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
}

