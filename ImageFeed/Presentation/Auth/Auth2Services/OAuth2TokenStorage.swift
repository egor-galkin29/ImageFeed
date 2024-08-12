import Foundation

final class OAuth2TokenStorage {
    private let storage = UserDefaults.standard
    private let tokenKey = "token"
    
    var token: String? {
        get {
            storage.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                storage.set(token, forKey: tokenKey)
            } else {
                storage.removeObject(forKey: tokenKey)
            }
        }
    }
}
