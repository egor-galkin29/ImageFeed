import Foundation

// MARK: - ProfileServiceError

enum ProfileServiceError: Error {
    case invalidRequest
    case invalidURL
    case noData
    case decodingError
    case missingProfileImageURL
}

// MARK: - JSONError

private enum JSONError: Error {
    case decodingError
}

// MARK: - ProfileService

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
// MARK: - Private Properties

    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
   
// MARK: - Private Methods

    // MARK: - makeURLRequest

    private func makeURLRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // MARK: - fetchProfile

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        guard lastToken != token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeURLRequest(token: token) else {
            print("Make URLRequest error")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileResult):
                    let profile = Profile(username: profileResult.username, firstname: profileResult.firstName, lastname: profileResult.lastName, bio: profileResult.bio)
                    self?.profile = profile
                    completion(.success(profile))
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
                self?.lastToken = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - cleanProfile

    func cleanProfile() {
        profile = nil
    }
}
