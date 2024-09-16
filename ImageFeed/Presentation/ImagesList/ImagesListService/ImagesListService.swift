//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Егор Галкин on 2024-09-09.
//

import Foundation
private enum PhotosResponseError: Error {
    case defaultError
}
struct UrlsResult: Codable {
    let full: String
    let thumb: String
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    private (set) var photos: [Photo] = []
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var isFetching = false
    private var currentPage = 0
    
    func fetchPhotosNextPage(completion: @escaping (Error?) -> Void) {
        guard !isFetching else { return }
        
        isFetching = true
        currentPage += 1
        
        let completionOnMainTheard:(Error?) -> Void = { error in
            DispatchQueue.main.async {
                completion(error)
                self.isFetching = false
            }
        }
        guard let request = makeFetchPhotosRequest(nextPage: currentPage) else {
            isFetching = false
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                print("переход к switch'у")
                switch result {
                case .success(let photoResult):
                    self?.processServerResponse(photoResult: photoResult)
                    completionOnMainTheard(nil)
                    print("Yes")
                case .failure:
                    self?.currentPage -= 1
                    completionOnMainTheard(PhotosResponseError.defaultError)
                }
            }
        }
        task.resume()
    }
    
    private func makeFetchPhotosRequest(nextPage: Int) -> URLRequest? {
        guard let url = URL(string: Constants.defaultPhotos + "?page=\(nextPage)"),
              let token = tokenStorage.token else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("request is done")
        return request
    }
    
    private func processServerResponse(photoResult: [PhotoResult]) {
        let newPhotos = photoResult.map { Photo(from: $0) }
        photos.append(contentsOf: newPhotos)
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }
}
