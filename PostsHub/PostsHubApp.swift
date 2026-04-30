// =====================================================================
// PostsHub — SwiftUI debugging exercise
//
// HOW TO RUN
// 1. Open PostsHub.xcodeproj in Xcode 15 or later.
// 2. Select an iOS 16+ simulator (e.g. "iPhone 15").
// 3. Press Cmd+R to build and run.
//
// If PostsHub.xcodeproj is missing, regenerate it with XcodeGen:
//     brew install xcodegen        # one-time setup
//     cd /path/to/PostsHub
//     xcodegen generate
//
// The app fetches data from https://jsonplaceholder.typicode.com.
// Network access from the simulator works out of the box; no
// Info.plist entries are required.
// =====================================================================

import SwiftUI

@main
struct PostsHubApp: App {
    init() {
        let info = Bundle.main.infoDictionary ?? [:]
        let version = info["CFBundleShortVersionString"] as? String ?? "?"
        let build = info["CFBundleVersion"] as? String ?? "?"
        let os = ProcessInfo.processInfo.operatingSystemVersionString
        Log.app.event("──── PostsHub launching ────")
        Log.app.event("version=\(version) build=\(build) os=\(os)")
        Log.app.event("baseURL=https://dummyjson.com")
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}
