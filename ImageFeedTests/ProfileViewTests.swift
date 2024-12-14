@testable import ImageFeed
import XCTest
import Foundation

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        // when
        _ = viewController.view
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsUpdateProfileDetails() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.view = viewController 
        // When
        presenter.viewDidLoad()
        // Then
        XCTAssertTrue(viewController.updateProfileDetailsCalled)
    }
    
    func testPresenterCallsShowBackButtonAlert() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        // When
        presenter.didTapBackButton()
        // Then
        XCTAssertTrue(viewController.showBackButtonAlertCalled)
    }
    
    func testViewControllerCallsDidTapBackButton() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        // When
        viewController.didTapBackButton() 
        // Then
        XCTAssertTrue(presenter.didTapBackButtonCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        // When
        presenter.viewDidLoad()
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)
        // Then
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
    
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    // MARK: - Флаги для отслеживания вызовов методов
    var viewDidLoadCalled = false
    var didTapBackButtonCalled = false
    // Ссылка на View (для связи Presenter -> View)
    weak var view: ProfileViewControllerProtocol?
    // MARK: - Методы протокола
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func didTapBackButton() {
        didTapBackButtonCalled = true
    }
}

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
