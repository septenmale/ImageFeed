import Foundation
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet  var likeButton: UIButton!
    @IBOutlet  var cellImage: UIImageView!
    @IBOutlet  var dateLabel: UILabel!
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    /// Prepares a reusable cell for reuse by the table view's delegate
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = UIImage(named: "placeholder")
        
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "liked") : UIImage(named: "disliked")
        likeButton.setImage(likeImage, for: .normal)
    }
    
}

extension ImagesListCell {
    /// prepares image for a next cell
    /// - Parameters:
    ///   - url: image URL
    ///   - indexPath: image's Index Path
    ///   - tableView: current Table View
    func configureImage(with url: URL, for indexPath: IndexPath, in tableView: UITableView) {
        setupLoadingIndicator()
        
        cellImage.kf.setImage(with: url,
                              placeholder: UIImage(named: "Stub") ?? UIImage()
        ) { result in }
        //TODO: Check if possible try to insert tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func setupLoadingIndicator() {
        cellImage.kf.indicatorType = .activity
    }
    
}
