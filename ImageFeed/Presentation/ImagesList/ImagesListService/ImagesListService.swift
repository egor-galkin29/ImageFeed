import Foundation

// MARK: - PhotosResponseError

private enum PhotosResponseError: Error {
    case defaultError
}

// MARK: - ImagesListService

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
// MARK: - Public Properties

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
// MARK: - Private Properties

    private (set) var photos: [Photo] = []
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage()
    private var changeLikeTask: URLSessionTask?
    
    private var isFetching = false
    private var currentPage = 0
    
// MARK: - Public Methods

    // MARK: - fetchPhotosNextPage

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
        
        guard let token = tokenStorage.token else { return }
        
        guard let request = makeFetchPhotosRequest(nextPage: currentPage, token: token) else {
            isFetching = false
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photoResult):
                self?.processServerResponse(photoResult: photoResult)
                completionOnMainTheard(nil)
            case .failure:
                self?.currentPage -= 1
                completionOnMainTheard(PhotosResponseError.defaultError)
            }
        }
        task.resume()
    }
    
    // MARK: - changeLike

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if changeLikeTask != nil {
            print("DEBUG",
                  "[\(String(describing: self)).\(#function)]:",
                  "Change like task is already in progress!",
                  separator: "\n")
            changeLikeTask?.cancel()
        }
        
        guard let token = tokenStorage.token else { return }
        
        guard let request = makeFetchLikeRequest(isLiked: isLike, photoID: photoId, token: token) else { return }
        
        let task = urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            
            guard let self else { return }
            
            if let error = error {
                self.changeLikeTask = nil
                completion(.failure(error))
                print("DEBUG",
                      "[\(String(describing: self)).\(#function)]:",
                      "Error while changing like:",
                      error.localizedDescription,
                      separator: "\n")
                return
            }
            
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let photo = self.photos[index]
                let newPhoto = Photo(photo: photo, isLiked: !photo.isLiked)
                DispatchQueue.main.async {
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                }
                
                completion(.success(Void()))
                self.changeLikeTask = nil
            }
        }
        changeLikeTask = task
        task.resume()
    }
    
    // MARK: - cleanImagesList

    func cleanImagesList() {
        photos.removeAll()
    }
  
// MARK: - Private Methods

    // MARK: - makeFetchPhotosRequest

    private func makeFetchPhotosRequest(nextPage: Int, token: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultPhotos + "?page=\(nextPage)"),
              let token = tokenStorage.token else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - makeFetchLikeRequest

    private func makeFetchLikeRequest(isLiked: Bool, photoID: String, token: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultPhotos + "\(photoID)/like"),
              let token = tokenStorage.token else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLiked ? "POST" : "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - processServerResponse

    private func processServerResponse(photoResult: [PhotoResult]) {
        let newPhotos = photoResult.map { Photo(from: $0) }
        photos.append(contentsOf: newPhotos)
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }
}
