@testable import ImageFeed
import XCTest
import Foundation

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
