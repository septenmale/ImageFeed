import Foundation
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentiifier = "ImagesListCell"
    
    @IBOutlet  var likeButton: UIButton!
    @IBOutlet  var cellImage: UIImageView!
    @IBOutlet  var dateLabel: UILabel!
    
    var imageDownloadTask: DownloadTask?
    
    // Переменная для хранения задачи на загрузку изображения
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageDownloadTask?.cancel()
        imageDownloadTask = nil
        
        cellImage.image = UIImage(named: "placeholder")
    }
        // TODO: в самой ячейке в prepareForReuse нужно отменить задачу на загрузку фото.
}

extension ImagesListCell {
    func configure(with url: URL) {
        // Настроим индикатор загрузки
        cellImage.kf.indicatorType = .activity
        
        // Настроим загрузку изображения с использованием Kingfisher
        imageDownloadTask = cellImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder")) { result in
            switch result {
            case .success(let value):
                print("[ImageListViewController]: Image successfully downloaded from \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("[ImageListViewController]: Error while downloading image: \(error.localizedDescription)")
            }
        }
    }
}
