import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            
        }
    }
    
    
    
    @IBOutlet  var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        }
    @IBAction func didTapBackButton(_ sender: UIButton) { dismiss(animated: true, completion: nil)
    }
    
}



extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
        
    }
}
