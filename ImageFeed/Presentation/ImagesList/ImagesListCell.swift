import UIKit

// MARK: - ImagesListCellDelegate

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    
// MARK: - IBOutlet

    @IBOutlet var cellImage: UIImageView!
    @IBOutlet private var likeButton: UIButton!
    @IBOutlet private var dateLable: UILabel!
    
// MARK: - Public Properties

    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    var gradientLayer: CAGradientLayer?
    
// MARK: - IBOutlet

    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
// MARK: - Public Methods

    // MARK: - prepareForReuse

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLable.text = nil
    }
    
    // MARK: - awakeFromNib

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addGradient()
    }
    
    // MARK: - layoutSubviews

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = cellImage.bounds
    }
    
    // MARK: - configure

    func configure(image: UIImage, text: String, isLiked: Bool) {
        gradientLayer?.isHidden = true
        
        let LikeButtonImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        
        cellImage.image = image
        dateLable.text = text
        likeButton.setImage(LikeButtonImage, for: .normal)
    }
    
    // MARK: - setIsLiked

    func setIsLiked(_ isLiked: Bool) {
        let LikeButtonImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        
        self.likeButton.setImage(LikeButtonImage, for: .normal)
    }
    
    // MARK: - addGradient

    func addGradient() {
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientLayer?.locations = [0, 0.1, 0.3]
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer?.frame = cellImage.bounds
        cellImage.layer.addSublayer(gradientLayer!)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientLayer?.add(gradientChangeAnimation, forKey: "locationsChange")
    }
}

