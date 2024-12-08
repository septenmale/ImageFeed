import Foundation

final class ImageListService {
    private(set) var photos: [Photo] = []
    // добавляю нотификацию
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    // на случай если уже идет загрузка
    private var lastTask: URLSessionTask?
    private var lastLoadedPage: Int?
    
    private let formatter = ISO8601DateFormatter()
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let baseUrl = Constants.defaultBaseURL else {
            print("[ImageListService]: [changeLike] - Error: Base URL is incorrect")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        guard let url = URL(string: "\(baseUrl)/photos/\(photoId)/like") else {
            print("[ImageListService]: [changeLike] - Error: Invalid URL")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImageListService]: [changeLike] - Error: OAuth token is missing.")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("Change like request URL: \(url.absoluteString)")
        print("Change like HTTP method: \(request.httpMethod ?? "nil")")
        
        guard let authHeader = request.value(forHTTPHeaderField: "Authorization") else {
            print("[ImageListService]: [changeLike] - Error: Failed to get Authorization header.")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        print("Authorization header: \(authHeader)")
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success:
                    guard let index = self.photos.firstIndex(where: { $0.id == photoId }) else {
                        print("[ImageListService]: [changeLike] - Error: Photo with ID \(photoId) not found.")
                        return }
                    // Текущий элемент
                    let photo = self.photos[index]
                    // Копия элемента с инвертированным значением isLiked
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked // Инвертируем значение
                    )
                    self.photos[index] = newPhoto
                    
                    completion(.success(()))
                    
                case .failure(let error):
                    print("[ImageListService]: [changeLike]: Error - \(error.localizedDescription).")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        // Проверяем, не идет ли уже запрос
        if lastTask != nil { lastTask?.cancel() }
        // Определяем номер следующей страницы
        let nextPage = (lastLoadedPage ?? 0) + 1
        // Генерируем запрос для указанной страницы
        guard let request = photosRequest(page: nextPage) else {
            print("[ImageListService]: [fetchPhotosNextPage]: Error while creating request for page \(nextPage)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResultResponseBody], Error>) in
            guard let self else { return }
            // потому что будет взаемодействие с UI
            DispatchQueue.main.async {
                // Сбрасываем текущую задачу
                self.lastTask = nil
                
                switch result {
                case.success(let response):
                    // Преобразуем массив PhotoResultResponseBody в массив Photo
                    let newPhotos = response.map { photoResult in
                        Photo(from: photoResult, formatter: self.formatter)
                    }
                    // Обновляем массив фотографий и последнюю загруженную страницу
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    // Отправляем уведомление об изменении данных
                    NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
                    // Завершаем с успешным результатом
                    completion(.success(newPhotos))
                    
                case .failure(let error):
                    // Выводим ошибку в лог и возвращаем ее в completion
                    print("[ImageListService]: [fetchPhotosNextPage]: Error fetching photos: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        // Сохраняем текущую задачу и запускаем ее
        self.lastTask = task
        task.resume()
    }
    
    private func photosRequest(page: Int) -> URLRequest? {
        let baseURL = "https://api.unsplash.com"
        
        guard let url = URL(string: "\(baseURL)/photos?page=\(page)") else {
            print("[ImageListService]: [photosRequest] - Error while creating url check func photosRequest")
            return nil
        }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImageListService]: [photosRequest] - Error: OAuth token is missing.")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("[photosRequest] - URL: \(url.absoluteString)")
        print("[photosRequest] - HTTP method: \(request.httpMethod ?? "nil")")
        guard let authHeader = request.value(forHTTPHeaderField: "Authorization") else {
            print("Error: Failed to get Authorization header.")
            return nil
        }
        print("[photosRequest] - Authorization header: \(authHeader)")
        
        return request
    }
}
