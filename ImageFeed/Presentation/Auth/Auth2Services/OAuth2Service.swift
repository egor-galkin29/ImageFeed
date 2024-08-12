import UIKit

final class OAuth2Service {
    
    static let shared = OAuth2Service(networkClient: NetworkClient())
    
    private let networkClient: NetworkRouting
    private let tokenStorage = OAuth2TokenStorage()

    init(networkClient: NetworkRouting) {
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
        
    func makeOAuthTokenRequest(code: String) -> URLRequest {
         let baseURL = URL(string: "https://unsplash.com")!
         let url = URL(
             string: "/oauth/token"
             + "?client_id=\(Constants.accessKey)"
             + "&&client_secret=\(Constants.secretKey)"
             + "&&redirect_uri=\(Constants.redirectURI)"
             + "&&code=\(code)"
             + "&&grant_type=authorization_code",
             relativeTo: baseURL
         )!
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         return request
     }
    
    func fetchOAuthToken(_ code: String, handler: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        networkClient.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(OAuth2Service.OAuthTokenResponseBody.self, from: data)
                    handler(.success(response.accessToken))
                    print("accessToken: \(response.accessToken) have been decoded")
                } catch {
                    handler(.failure(error))
                    print("failed decode")
                }
            case .failure(let error):
                handler(.failure(error))
                print("failed authorisation")
            }
        }
    }
}
