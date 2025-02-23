# MatchMate
MatchMate - Matrimonial Card Interface
Overview
MatchMate is a matrimonial application that fetches match cards from an API, allowing users to accept or decline matches. The app supports offline functionality using Core Data for persistence and automatically syncs data when the network is available.

Features
Fetch match profiles from API
Accept/Decline matches
Offline support with Core Data caching
Background sync when internet is restored
Clean and intuitive UI with SwiftUI
Dependency Injection and SOLID principles
Unit tests for critical components

Tech Stack
Language: Swift 5
Architecture: MVVM (Model-View-ViewModel)
UI Framework: SwiftUI
Networking: Alamofire
Image Caching: SDWebImageSwiftUI
Reactive Programming: Combine
Offline Storage: Core Data
Dependency Injection: Using protocols and mockable services

Setup Instructions
Installation Steps
Clone the repository: git clone https://github.com/nivruttikokane/MatchMate.git
cd MatchMate
Install dependencies using Swift Package Manager (SPM):
Alamofire
SDWebImageSwiftUI
Open MatchMate.xcodeproj in Xcode.
Select a target device and run the app (Cmd + R).

Offline Mode
Matches are saved in Core Data for offline access.
Accept/Decline actions are queued and synced when online.

Unit Testing
Run tests using Cmd + U in Xcode.
Includes test cases for ProfileMatchesViewModel, NetworkConnectivityService, and Core Data operations.
