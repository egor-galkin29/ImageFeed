import Foundation

// MARK: - Photo

struct Photo {
    private let dateFormatter = DateConvertor.shared
    
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    init(from photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        createdAt = dateFormatter.getDateFromString(from: photoResult.createdAt)
        welcomeDescription = photoResult.description
        thumbImageURL = photoResult.urls.thumb
        largeImageURL = photoResult.urls.full
        isLiked = photoResult.likedByUser
    }
    
    init(photo: Photo, isLiked: Bool) {
        self.id = photo.id
        self.size = photo.size
        self.createdAt = photo.createdAt
        self.welcomeDescription = photo.welcomeDescription
        self.largeImageURL = photo.largeImageURL
        self.thumbImageURL = photo.thumbImageURL
        self.isLiked = isLiked
    }
}
