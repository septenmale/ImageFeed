import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication() // переменная приложения
    // выполняет запуск приложения
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    // тестируем сценарий авторизации
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 20))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 15))
        
        loginTextField.tap()
        loginTextField.typeText("zavhorodnii.viktor@icloud.com")
//        app.keyboards.buttons["Go"].tap() - второй способ перейти к вводу пароля.
        app.tap()
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 15))
        
        passwordTextField.tap()
        passwordTextField.typeText("Fuwtyg-jysjus-zafqu4")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        // тестируем сценарий ленты
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля
    }
    
}
