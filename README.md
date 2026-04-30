# PostsHub

A small SwiftUI app for browsing, favoriting, and editing blog posts. Your task is to find and fix the intentional bugs in it.

## Requirements
- Xcode 15 or later
- iOS 17+ simulator
- Internet access (the app calls a public API)

## Setup
1. Open `PostsHub.xcodeproj` in Xcode.
2. Choose any iOS 17+ simulator.
3. Press `Cmd+R` to build and run.

If the `.xcodeproj` is missing, regenerate it with [XcodeGen](https://github.com/yonaskolb/XcodeGen):
```sh
brew install xcodegen
xcodegen generate
```

## What the app does

Data is fetched from [DummyJSON](https://dummyjson.com) (`/posts`, `/posts/search`, `/users`). The API is read-only — any "saved" edit lives only in memory for the session.

### Screens & navigation
- **Posts** (tab 1) — list of posts with a search bar and a user-filter button (top-right). Tap a row to open the Detail screen. Pull down to refresh. Swipe a row left to delete.
- **Favorites** (tab 2) — posts you've marked with the heart icon.
- **Post Detail** — pushed from the Posts list. Edit title and body, save changes, toggle favorite.
- **User Filter Sheet** — modal sheet launched from the Posts tab toolbar; pick an author to filter the list.

## The challenge

The app builds and runs, but contains **14 intentional bugs**. They fall into these categories:

- 2 UI / layout bugs
- 2 State-management bugs
- 2 Codable / decoding bugs
- 2 Crash bugs
- 2 Performance or threading bugs
- 4 Mixed bonus bugs (SwiftUI identity, animations, search, async)

For each bug you find, please explain:
1. What you observed.
2. What is causing it.
3. How you would fix it (and why your fix is the right one).

Watch the Xcode console while you exercise the app — several bugs surface there first. Logs use Apple's unified logging (`os.Logger`) under the subsystem `com.brivo.claude.postshub`. Useful categories: `App`, `API`, `Store`, `List`, `Detail`, `Row`, `Favorites`, `Filter`. You can filter in Console.app or in Xcode's debug area.

Tip: long‑press the filter button (top‑right of the Posts tab) for ~1 second to dump the current `PostStore` state to the log.

### Sample API responses

`GET https://dummyjson.com/posts?limit=1`
```json
{
  "posts": [
    {
      "id": 1,
      "title": "His mother had always taught him",
      "body": "His mother had always taught him not to ever think of himself as better than others...",
      "tags": ["history", "american", "crime"],
      "reactions": { "likes": 192, "dislikes": 25 },
      "views": 305,
      "userId": 121
    }
  ],
  "total": 251, "skip": 0, "limit": 1
}
```

`GET https://dummyjson.com/users?limit=1`
```json
{
  "users": [
    {
      "id": 1,
      "firstName": "Emily", "lastName": "Johnson", "username": "emilys",
      "email": "emily.johnson@x.dummyjson.com", "phone": "+81 965-431-3024",
      "image": "https://dummyjson.com/icon/emilys/128",
      "address": {
        "address": "626 Main Street", "city": "Phoenix", "state": "OK",
        "postalCode": "31313",
        "coordinates": { "lat": -77.16482, "lng": -92.084824 }
      }
    }
  ],
  "total": 208, "skip": 0, "limit": 1
}
```
