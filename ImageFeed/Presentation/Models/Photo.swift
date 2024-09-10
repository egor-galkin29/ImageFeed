//
//  Photo.swift
//  ImageFeed
//
//  Created by Егор Галкин on 2024-09-09.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(from photoResult: PhotoResult) {
            id = photoResult.id
            size = CGSize(width: photoResult.width, height: photoResult.height)
            createdAt = CustomDateFormatter.shared.iso8601DateFormatter.date(from: photoResult.createdAt)
            welcomeDescription = photoResult.description
            thumbImageURL = photoResult.urls.thumb
            largeImageURL = photoResult.urls.full
            isLiked = photoResult.likedByUser
        }
}
