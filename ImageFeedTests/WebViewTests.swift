@testable import ImageFeed
import XCTest
import Foundation

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        // when
        _ = viewController.view
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
        // в общем моку мы далаем то что проверяем в тесте как я понял
    }
    
    func testPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        // when
        presenter.viewDidLoad()
        // then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.9
        // when
        let shouldHideProgressValue = presenter.shouldHideProgress(for: progress)
        // then
        XCTAssertFalse(shouldHideProgressValue)
    }
    
    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        // then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthUrl() {
        // given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        // when
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("URL should not be nil")
            return
        }
        // then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromUrl() {
        // given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        // when
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native") else {
            XCTFail("urlComponents should not be nil")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "code", value: "test code")
        ]
        
        guard let url = urlComponents.url else {
            XCTFail("url should not be nil")
            return
        }
        // then
        XCTAssertEqual(authHelper.code(from: url), "test code")
    }
    
}

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
    
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadRequestCalled: Bool = false
    var presenter: WebViewPresenterProtocol?
    
//    func loadRequest(request: URLRequest) {
//        loadRequestCalled = true
//    }
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
    
}

