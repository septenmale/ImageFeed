📷 **Unsplash Image Viewer**

Unsplash Image Viewer is a multi-page iOS application for exploring high-quality images from the Unsplash Editorial API. The app allows users to browse an infinite image feed, like and favorite photos, view personal profile details, and share images with others.

🔧 **Technical Highlights**

Networking & API Integration:
	•	Integrated with the Unsplash API to fetch images and user profile data.
	•	Performed API requests using URLSession for secure and efficient networking.

Secure Data Storage:
	•	Stored sensitive user information (e.g., OAuth tokens) securely in Keychain.

Custom View Implementation:
	•	Developed one view controller entirely programmatically, showcasing a deep understanding of auto layout constraints without relying on Storyboards.

 Dependency Management:
	•	Used Swift Package Manager (SPM) to integrate and manage third-party libraries for image caching and optimized API handling.

**UI/UX:**
	•	Built a responsive, user-friendly interface using:
	•	UITableView for infinite scrolling of images.
	•	UIImageView, UIButton, and UILabel for visual and interactive elements.
	•	Tab Bar navigation for seamless switching between the feed and profile screens.

 🛠 **Tools and Technologies**
	•	Language: Swift
	•	IDE: Xcode
	•	iOS Version: 13+ (Portrait mode only)
	•	Architecture: MVC (to be refactored to MVP)
	•	Dependencies: Swift Package Manager
	•	Key Libraries:
	•	[*Unsplash API*](https://unsplash.com/documentation)

 📌 Planned Improvements
	•	Refactor to MVP Architecture for better scalability and testability.
	•	Add Unit Tests and UI Tests for ensuring robust functionality.
