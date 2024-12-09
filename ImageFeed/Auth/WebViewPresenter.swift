import Foundation

public protocol WebViewPresenterProtocol {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    var view: WebViewViewControllerProtocol? { get set }
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else {
            print("[WebViewPresenter]: [viewDidLoad] - Error: Failed to create auth request.")
            return
        }
        
        didUpdateProgressValue(0)
        view?.load(request: request)
    }
    
    /// - Description: Определяет, какое значение прогресса задать для progressView и когда его скрывать
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    /// - Description: Функция вычисления того, должен ли быть скрыт progressView.
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    /// - Description: Анализирует URL и достаёт из него код, если он есть.
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
}
