import UIKit

final class OAuth2Service {
    
    static let shared = OAuth2Service(networkClient: NetworkClient())
    
    private var networkClient: NetworkClient
    private let tokenStorage = OAuth2TokenStorage()
    
    private var lastCode: String?
    
    private enum JSONError: Error {
            case decodingError
        }
    
    private enum AuthServiceError: Error {
        case invalidRequest
    }
    
    private init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    struct OAuthTokenResponseBody: Decodable {
            let accessToken: String
            let tokenType: String

            private enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case tokenType = "token_type"
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                accessToken = try container.decode(String.self, forKey: .accessToken)
                tokenType = try container.decode(String.self, forKey: .tokenType)
            }
        }
    
    private(set) var authToken: String? {
            get {
                return tokenStorage.token
            }
            set {
                tokenStorage.token = newValue
            }
        }
        
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
             let baseURL = URL(string: "https://unsplash.com")
             guard let url = URL(
                 string: "/oauth/token"
                 + "?client_id=\(Constants.accessKey)"
                 + "&&client_secret=\(Constants.secretKey)"
                 + "&&redirect_uri=\(Constants.redirectURI)"
                 + "&&code=\(code)"
                 + "&&grant_type=authorization_code",
                 relativeTo: baseURL
             ) else {
                 return nil
             }
             var request = URLRequest(url: url)
             request.httpMethod = "POST"
             return request
         }
    
    func fetchOAuthToken(_ code: String, handler: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            fatalError("Unable to create fetch authorization token request")
        }
        
        guard lastCode != code else {
                    handler(.failure(AuthServiceError.invalidRequest))
                    return
                }
        
        networkClient.task?.cancel()
        lastCode = code
        
        networkClient.data(for: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(OAuth2Service.OAuthTokenResponseBody.self, from: data)
                        handler(.success(response.accessToken))
                        print("accessToken: \(response.accessToken) have been decoded")
                    } catch {
                        handler(.failure(JSONError.decodingError))
                        print("JSON decoding error \(error.localizedDescription)")
                    }
                case .failure(let error):
                    handler(.failure(error))
                    print(error.localizedDescription)
                }
                self.networkClient.task = nil
                self.lastCode = nil
            }
        }
    }
}
