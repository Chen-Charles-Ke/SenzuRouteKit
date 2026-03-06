# SenzuRouteKit

A production-oriented navigation framework for **UIKit + SwiftUI** apps.

`SenzuRouteKit` provides:
- A unified route model (`RoutePath`, `Route`, `Router`)
- Multi-target route registration (`RoutableViewModel`, `UIViewController`, action/SDK entry)
- A SwiftUI hosting bridge (`RoutableHostingController`)
- Built-in DI integration (`SenzuDI`, `@SenzuInjected`) backed by Resolver
- Optional one-line bootstrap (`QuickRouter.start`)

---

## Table of Contents

1. [Why SenzuRouteKit](#why-senzuroutekit)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Core Concepts](#core-concepts)
5. [API Reference](#api-reference)
6. [DI API](#di-api)
7. [Navigation Behavior](#navigation-behavior)
8. [Deep Link](#deep-link)
9. [Best Practices](#best-practices)
10. [Roadmap](#roadmap)

---

## Why SenzuRouteKit

Most app projects end up duplicating the same navigation glue:
- route lookup
- push/present decisions
- root replacement
- hosting SwiftUI inside UIKit
- DI wiring

`SenzuRouteKit` centralizes these concerns into reusable primitives so feature code stays focused on business logic.

---

## Installation

### Xcode (Recommended)

Add package dependency:

- URL: `https://github.com/Chen-Charles-Ke/SenzuRouteKit.git`
- Version: `1.2.0`

Then link product:
- `SenzuRouteKit`

### Swift Package Manager

```swift
.package(url: "https://github.com/Chen-Charles-Ke/SenzuRouteKit.git", exact: "1.2.0")
```

### CocoaPods

```ruby
platform :ios, '13.0'

target 'YourApp' do
  use_frameworks!
  pod 'SenzuRouteKit', :git => 'https://github.com/Chen-Charles-Ke/SenzuRouteKit.git', :tag => '1.2.0'
end
```

Then run:

```bash
pod install
```

If you later publish to CocoaPods Trunk, you can switch to:

```ruby
pod 'SenzuRouteKit', '1.2.0'
```

---

## Quick Start

### Option A: One-line bootstrap (no manual DI setup)

```swift
import SenzuRouteKit

let router = QuickRouter.start(
    in: window,
    startPath: AppRoutes.home,
    routes: AppRoutes.registeredRoutes(),
    navType: MainNavigationController.self,
    routeHandler: self
)
```

### Option B: DI-first bootstrap (recommended for larger apps)

```swift
import SenzuRouteKit

SenzuDI.register({ MainApplication() as MainApplication }, scope: .application)
SenzuDI.registerRouter(
    navType: MainNavigationController.self,
    startPath: AppRoutes.home,
    routeHandler: self,
    scope: .application
)

let router: Router = SenzuDI.resolve()
router.bind(routes: AppRoutes.registeredRoutes())
router.start()
```

---

## Core Concepts

### 1) `RoutePath`
Strongly identifies a destination.

```swift
enum AppRoutes: RoutePath {
    case home
    case profile

    var path: String {
        switch self {
        case .home: return "/home"
        case .profile: return "/profile"
        }
    }
}
```

### 2) `Route`
Binds a `RoutePath` to one of three target types.

```swift
[
    Route(path: AppRoutes.home, type: HomeViewModel.self),
    Route(path: AppRoutes.profile, viewControllerFactory: { _ in ProfileViewController() }),
    Route(path: AppRoutes.openSDK, action: { context in
        ThirdPartySDK.launch(from: context.navigationController.visibleViewController!)
    })
]
```

### 3) `RoutableViewModel`
The navigation-facing contract for each screen.

```swift
final class HomeViewModel: RoutableViewModel {
    required init(parameters: [String : Any]?) throws {}

    var routedView: AnyView { AnyView(HomeView(viewModel: self)) }
    var isRootView: Bool { true }
    var showTabBar: Bool { true }
}
```

### 4) `Router`
Performs navigation and route lifecycle operations.

---

## API Reference

### `Router`

- `bind(route:)` / `bind(routes:)`: register destination(s)
- `unbind(route:)` / `unbind(routes:)` / `unbindAll()`: unregister destination(s)
- `navigate(to:parameters:isDeepLink:animated:)`: go to route (extension helper)
- `route(to:parameters:isDeepLink:animated:)`: low-level navigation entry
- `dismiss(animated:)`: pop or dismiss current route
- `start(animated:)`: navigate to configured `startPath`
- `logout()`: alias for start/reset behavior

### `Route`

- `path`: route identifier
- `target`: route target enum (`viewModel`, `viewController`, `action`)
- `type`: optional convenience accessor for `RoutableViewModel` routes
- `presentModally`: uses modal presentation when true
- `requiresAuthentication`: metadata hook for auth flow policies
- `isRootRoute`: force route result to replace root controller
- `showTabBar`: optional tab visibility override for this route

### `RoutableViewModel`

Required:
- `init(parameters:)`
- `routedView`

Optional customization (default implementations provided):
- `isRootView`
- `showTabBar`
- `navigationBarStyle` (`.solid`, `.transparent`, `.hidden`)
- `preferredStatusBarStyle`
- `titleText`, `titleTextPublisher`, `titleTextAttributes`
- `modalTransitionStyle`, `modalPresentationStyle`
- `enableNavItems`

### `RoutableNavigationController`

Custom `UINavigationController` implementations should conform to:
- `showTab(path:)`
- `hideTabBar()`
- `reloadTabs()`

Use this to keep tab logic app-specific while reusing route core.

### `RouteHandler`

Hooks for nav bar corner actions:
- `leftCornerIcon()`
- `rightCornerIcon()`

---

## DI API

`SenzuRouteKit` exposes a simplified DI surface so app code does not need direct Resolver calls.

### `@SenzuInjected`

```swift
@SenzuInjected var router: Router
@SenzuInjected var themeManager: ThemeManager
```

### `SenzuDI.register`

```swift
SenzuDI.register({ ThemeManager() as ThemeManager }, scope: .application)
```

### `SenzuDI.resolve`

```swift
let router: Router = SenzuDI.resolve()
```

### `SenzuDI.registerRouter`

```swift
SenzuDI.registerRouter(
    navType: MainNavigationController.self,
    startPath: AppRoutes.home,
    routeHandler: self,
    scope: .application
)
```

### `SenzuDIScope`

Supported scopes:
- `.application`
- `.cached`
- `.graph`
- `.shared`
- `.unique`

---

## Navigation Behavior

`NavigationRouter` behavior summary:

- If route is not found: assertion failure (debug), no-op (runtime safe)
- If ViewModel init fails: assertion failure (debug), no-op
- If target is `viewModel`:
  - build `RoutableHostingController` from your view model
- If target is `viewController`:
  - build and navigate a UIKit controller directly
- If target is `action`:
  - execute closure with `RouteActionContext` (ideal for SDK entry points)
- If `presentModally == false` (viewModel/viewController):
  - pop to existing route if already in stack
  - else push new hosting controller
  - if `isRootView == true` or `isRootRoute == true`, replace root controller
- If `presentModally == true`:
  - present from top-most visible controller

---

## Deep Link

`SenzuRouteKit` includes a standard deep link module:

- `URLPattern`: URL matcher with scheme/host/path-template support
- `StandardDeepLinkParser`: rule-based parser (`URL -> DeepLinkDestination`)
- `DeepLinkCoordinator`: handles URL/UserActivity, supports pending queue before router is ready

### Core types

```swift
public struct URLPattern
public struct DeepLinkRule
public protocol DeepLinkParser
public struct StandardDeepLinkParser
public struct DeepLinkDestination
public final class DeepLinkCoordinator
```

### Path-template example

```swift
let pattern = URLPattern(
    schemes: ["https"],
    hosts: ["senzu.app"],
    pathTemplate: "/open/:tab"
)
```

### Parser example

```swift
let parser = StandardDeepLinkParser(rules: [
    DeepLinkRule(pattern: URLPattern(schemes: ["https"], hosts: ["senzu.app"], pathTemplate: "/summary")) { match in
        DeepLinkDestination(path: AppRoutes.summary, parameters: match.queryParameters)
    }
])
```

### Coordinator example

```swift
let coordinator = DeepLinkCoordinator(
    parser: parser,
    routerProvider: { SenzuDI.resolve(Router.self) }
)

_ = coordinator.handle(url: incomingURL)
_ = coordinator.handle(userActivity: userActivity)
coordinator.flushPending()
```

---

## Best Practices

1. Keep `RoutePath` stable and unique across features.
2. Keep route parameters minimal; prefer IDs over full models.
3. Treat `[String: Any]` as transitional; migrate to typed params wrappers over time.
4. Use `isRootView` only for true root transitions.
5. Keep tab-bar logic inside your custom navigation controller.

---

## Roadmap

- Typed route parameter support
- Better route diagnostics / logging hooks
- Optional deep-link parser utilities
- Test helpers for route registration and navigation assertions
