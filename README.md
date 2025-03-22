# Image Feed

## Links
- **Design in Figma**: [link]
- **Unsplash API**: [link]

## Purpose and Goals
**Image Feed** is a multi-page application designed for viewing images via the Unsplash API.

### Application Goals:
- View an endless feed of images from Unsplash Editorial.
- View brief user profile information.

## Brief Description
- Authorization via OAuth Unsplash is required.
- The main screen consists of an image feed. Users can browse, add, and remove images from favorites.
- Users can view images individually and share links to them.
- A user profile displays favorite images and basic user information.
- The app has two versions: **basic** and **extended** (with favorites and like functionality).

## Non-Functional Requirements
### Technical Requirements
- Authorization via OAuth Unsplash with a POST request to obtain an Auth Token.
- Feed implemented using `UITableView`.
- Main UI components: `UIImageView`, `UIButton`, `UILabel`, `TabBarController`, `NavigationController`, `NavigationBar`, `UITableView`, `UITableViewCell`.
- Supports iPhone devices with iOS 13+ (portrait mode only).
- Uses system fonts (`SF Pro` for iOS 13-16).

## Functional Requirements
### OAuth Authorization
#### Authorization Screen Includes:
- App logo
- "Login" button

#### Login Algorithm:
1. User sees **splash screen**.
2. After loading, the authorization screen appears.
3. Pressing "Login" opens a browser for Unsplash authentication.
4. On success, the feed screen opens.
5. If authentication fails, a modal error window appears.

### Feed Viewing
#### Feed Screen Includes:
- Image card
- Like button
- Upload date
- Tab bar for navigation

#### Actions:
- The feed loads automatically upon login.
- Users can scroll through images.
- If an image fails to load, a placeholder appears.
- Pressing "Like":
  - Gray heart → red (if successful)
  - On failure, a modal error window appears.
- Pressing an image opens it in full-screen mode.
- Users can switch between the feed and profile via the tab bar.

### Full-Screen Image Viewing
#### Screen Includes:
- Enlarged image
- "Back" button
- "Share" button

#### Actions:
- Users can zoom, rotate, and move the image.
- If the image fails to load, a placeholder appears.
- Pressing "Share" opens the system menu.

### User Profile Viewing
#### Profile Screen Includes:
- User photo
- Name, username
- User bio
- "Logout" button

#### Actions:
- Data is loaded from Unsplash.
- If loading fails, a placeholder appears.
- Logging out prompts a system confirmation alert.

## Extended Version
### Favorites
- Pressing "Like" adds an image to favorites.
- Favorites are displayed in the user profile.
- Users can remove images from favorites.
- A counter shows the number of favorite images.

### Additional Features
- Like images in full-screen mode.
- Placeholder when no images are available.
- Switch between feed and profile.

---

### License
This project is distributed under the MIT License.
