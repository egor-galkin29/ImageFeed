import Foundation

// MARK: - ProfileImageService

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    // MARK: - Public Properties
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    let storage = OAuth2TokenStorage()
    
    // MARK: - Private Properties
    
    private (set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    // MARK: - Public Methods
    
    // MARK: - fetchProfileImageURL
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastUsername != username else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastUsername = username
        
        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(ProfileServiceError.invalidURL))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userResult):
                    let profileImageURL = userResult.profileImage.small
                    self?.avatarURL = profileImageURL
                    completion(.success(profileImageURL))
                    
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImageURL])
                    
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .httpStatusCode(let statusCode):
                            print("HTTP status code error: \(statusCode)")
                        case .urlRequestError(let requestError):
                            print("URL request error: \(requestError)")
                        case .urlSessionError:
                            print("URL session error: \(error)")
                        }
                    } else {
                        print("Other network error: \(error)")
                    }
                    completion(.failure(error))
                }
                self?.task = nil
                self?.lastUsername = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - cleanAvatar
    
    func cleanAvatar() {
        avatarURL = nil
    }
    
    // MARK: - Private Methods
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        guard let url = URL(string: "/users/\(username)", relativeTo: baseURL) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(storage.token ?? "")", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
