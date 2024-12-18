@testable import ImageFeed
import XCTest
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    // MARK: - Флаги для отслеживания вызовов методов
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var showBackButtonAlertCalled = false
    // Ссылка на Presenter (для связи View -> Presenter)
    var presenter: ProfileViewPresenterProtocol?
    // MARK: - Методы протокола
    func updateProfileDetails(profile: ImageFeed.Profile) {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func showBackButtonAlert() {
        showBackButtonAlertCalled = true
    }
}
