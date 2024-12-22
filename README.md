# **📷 Unsplash Image Viewer**

**Unsplash Image Viewer** is a multi-page iOS application for exploring high-quality images from the Unsplash Editorial API. The app allows users to browse an infinite image feed, like and favorite photos, view personal profile details, and share images with others.

## **🎯 Project Features**

### **Core Functionality:**
- **OAuth Authorization:** Secure login via Unsplash OAuth.
- **Image Feed:**
  - Infinite scrolling feed displaying curated images from Unsplash Editorial.
  - View each image in fullscreen mode with zoom and pan gestures.
  - Like or unlike images in the feed and fullscreen mode.
  - Add images to favorites (in extended version).
- **User Profile:**
  - Displays user avatar, username, and bio retrieved from the Unsplash API.
  - View and manage favorited images.
  - Logout functionality with confirmation dialog.
- **Sharing:** Users can share individual images outside the app.

---

## **🔧 Technical Highlights**

### **Networking & API Integration:**
- Integrated with the Unsplash API to fetch images and user profile data dynamically.
- Performed network requests using `URLSession`, ensuring secure and efficient API interaction.

### **Architecture & Code Structure:**
- Refactored the project to follow the **MVP architecture**, enabling better testability and scalability.
- Ensured clear separation of responsibilities between **Model, View, and Presenter**.

### **Testing:**
- Added comprehensive **Unit Tests** for core business logic.
- Implemented **UI Tests** to validate user interactions and ensure smooth navigation.

### **Secure Data Storage:**
- Stored sensitive user information (e.g., OAuth tokens) securely in **Keychain** to enhance information security.

### **Custom View Implementation:**
- Developed one view controller entirely programmatically, leveraging auto layout constraints for flexibility and cleaner design.

### **Dependency Management:**
- Used **Swift Package Manager (SPM)** to manage third-party libraries, improving maintainability and simplifying setup.

### **UI/UX:**
- Built a responsive, user-friendly interface using:
  - `UITableView` for infinite scrolling of images.
  - `UIImageView`, `UIButton`, and `UILabel` for visual and interactive elements.
  - Tab Bar navigation for seamless switching between the feed and profile screens.

---

## **🛠 Tools and Technologies**
- **Language:** Swift  
- **IDE:** Xcode  
- **iOS Version:** 13+ (Portrait mode only)  
- **Architecture:** MVP  
- **Testing:** XCTest for Unit and UI Tests  
- **Dependency Management:** Swift Package Manager  
- **Key Libraries:** [Unsplash API](https://unsplash.com/documentation)

---

### **🤝 Contributions**
- Contributions, issues, and feature requests are welcome! Feel free to submit a pull request or open an issue to improve this project.

---

## **📧 Contact**
- If you have any questions or feedback, feel free to reach out via [LinkedIn](https://linkedin.com/in/zavhorodniiviktor) or open an issue in this repository.
