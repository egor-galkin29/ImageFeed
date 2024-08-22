import Foundation

enum ProfileServiceError: Error {
    case profileNotFound
}

private enum JSONError: Error {
        case decodingError
    }

struct ProfileResult: Codable {
    var username: String
    var firstName: String
    var lastName: String?
    var bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(username: String, firstname: String, lastname: String?, bio: String?) {
        self.username = username
        
        if let lastname {
            name = firstname + " " + lastname
        } else {
            name = firstname
        }
        
        self.loginName = "@" + username
        self.bio = bio
    }
}

final class ProfileService {
    static let shared = ProfileService(networkClient: NetworkClient())
    private init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    private(set) var profile: Profile?
    
    private var networkClient: NetworkClient
    
    private func makeURLRequest(token: String) -> URLRequest? {
            guard let url = URL(string: "https://api.unsplash.com/me") else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeURLRequest(token: token) else {
                print("Make URLRequest error")
                return
        }
        networkClient.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(ProfileResult.self, from: data)
                    self.profile = Profile(username: response.username, firstname: response.firstName, lastname: response.lastName, bio: response.bio)
                    
                    if let profile = self.profile {
                        completion(.success(profile))
                    } else {
                        completion(.failure(ProfileServiceError.profileNotFound))
                    }
                } catch {
                    completion(.failure(JSONError.decodingError))
                    print("JSON decoding error \(error.localizedDescription)")
                }
            case .failure(let error):
                print("FetchProfile - \(error)")
                completion(.failure(error))
            }
        }
    }
}
