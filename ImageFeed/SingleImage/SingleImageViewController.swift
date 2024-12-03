import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var imageURL: URL?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        loadImageIfNeeded()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton()  {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func loadImageIfNeeded() {
        guard let imageURL = imageURL else {
            print("[SingleImageViewController]: [loadImageIfNeeded]: Error - Image URL is nil")
            return
        }
        loadImage(from: imageURL)
    }
    
    private func loadImage(from url: URL) {
        UIBlockingProgressHud.show()
        
        // Использование DownsamplingImageProcessor для уменьшения изображения до размера экрана
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
            .append(another: ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFit))
        
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "Stub") ?? UIImage(),
                              options: [
                                .processor(processor),
                                // возвращает коэффициент масштабирования для экрана устройства
                                .scaleFactor(UIScreen.main.scale),
                                // будет хранить оригинальную версию изображения в кэше, а не изменённую
                                .cacheOriginalImage
                              ]
        ){ [weak self] result in
            UIBlockingProgressHud.dismiss()
            
            guard let self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure(let error):
                print("[SingleImageViewController]: [loadImage]: Error - \(error.localizedDescription).")
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так" ,
                                      message: "Попробовать еще раз?",
                                      preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "Не надо", style: .cancel) { _ in }
        let yesAction = UIAlertAction(title: "Повторить", style: .default) { _ in
            self.loadImageIfNeeded()
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
