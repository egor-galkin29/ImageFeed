import Foundation

// MARK: - Profile

public struct Profile {
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
