protocol WebViewViewContrrollerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    )
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
