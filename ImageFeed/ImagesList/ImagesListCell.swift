import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentiifier = "ImagesListCell"
    
    @IBOutlet  var likeButton: UIButton!
    @IBOutlet  var cellImage: UIImageView!
    @IBOutlet  var dateLabel: UILabel!
}
