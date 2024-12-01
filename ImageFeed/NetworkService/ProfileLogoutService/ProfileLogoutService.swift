import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        cleanCookies()
        cleanToken()
        cleanUserInfo()
    }
    
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanToken() {
        if let token = OAuth2TokenStorage.shared.token {
                print("[OAuth2TokenStorage]: Token found: \(token)")
                OAuth2TokenStorage.shared.token = nil
            } else {
                print("[OAuth2TokenStorage]: No token found to remove")
            }
    }
    
    private func cleanUserInfo() {
    let profileViewController = ProfileViewController()
        profileViewController.cleanProfileData()
    }
    
}

