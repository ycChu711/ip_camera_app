# IP Camera Streaming App

This is a Flutter application that streams video from an IP camera. The app is designed to run on multiple platforms, including Android, iOS, web, macOS, Linux, and Windows.

## Features

- Real-time video streaming
- Multi-platform support
- User-friendly interface

## Getting Started

### Prerequisites

Ensure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install)
- Platform-specific requirements:
  - **Android**: [Android Studio](https://developer.android.com/studio)
  - **iOS/macOS**: [Xcode](https://developer.apple.com/xcode/)
  - **Windows**: [Visual Studio](https://visualstudio.microsoft.com/)
  - **Linux**: Development tools (GCC, CMake, etc.)

### Cloning the Repository

Clone the repository to your local machine:

```sh
git clone -b [your-branch-name] https://github.com/ycChu711/ip_camera_app.git
cd ip_camera_app
```

### Installing Dependencies

Navigate to the project directory and install the necessary dependencies:
```sh
flutter pub get
```

### Platform-Specific Setup

#### Android
1.	Ensure Android Studio is installed.
	
2.	Install Android SDK and necessary tools.

3.	If local.properties is not generated, create it manually with the SDK path.

#### iOS
1.	Ensure Xcode is installed.
2.	##### Please follow these steps to configure the iOS project:
   
   	1. Open the project in Xcode:
   	```sh
   	open ios/Runner.xcworkspace
	```
	2.	Set the Development Team and Code Signing Identity:
		- Go to the project settings and set your Development Team under the Signing & Capabilities tab for both the Runner and RunnerTests targets.
		- Ensure the correct Code Signing Identity is selected.

	3.	Set the Product Bundle Identifier:
		- Go to the project settings and set your unique Bundle Identifier under the General tab for both the Runner and RunnerTests targets.

3.	Install CocoaPods if not already installed:
```sh
sudo gem install cocoapods
```
3.	Navigate to the ios directory and run:
```sh
cd ios
pod install
cd ..
```

#### macOS
1.	Ensure Xcode is installed.

2.	Install CocoaPods if not already installed:
```sh
sudo gem install cocoapods
```
3.	Navigate to the macos directory and run:
```sh
cd macos
pod install
cd ..
```

#### web
1.	Ensure you have a compatible web browser and development tools.

#### Linux
1.	Ensure the necessary development tools are installed (GCC, CMake, etc.).

### Running the App
To run the app, use the following command:
```sh
flutter run
```
