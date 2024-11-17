import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    private init() {}
    
    private let tokenKey = "OAuthToken" // a place for key
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey) // receiving token from keychain
        }
        set {
            if let newValue = newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey) // saving token
                guard isSuccess else {
                    print("[OAuth2TokenStorage]: Error saving token to Keychain")
                    return
                }
            } else {
                let isRemoved: Bool = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                guard isRemoved else {
                    print("[OAuth2TokenStorage]: Error removing token from Keychain")
                    return
                }
            }
        }
    }
    
}


