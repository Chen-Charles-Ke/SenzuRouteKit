# SenzuRouteKit

把 `UIKit + SwiftUI` 的页面路由统一在一个可复用包里。

## 能力

- 统一管理 route 注册与跳转
- SwiftUI 页面通过单一 `RoutableHostingController` 承载
- 支持 push / present
- 支持 root route 覆盖
- 支持自定义导航容器（含你自己的 tab bar 控制）

## 安装

在 Xcode 的 **Package Dependencies** 里添加本地路径：

`/Users/charles/code/senzuProject/SenzuRouteKit`

## 一行启动

```swift
let router = QuickRouter.start(
    in: window,
    startPath: AppRoutes.home,
    routes: AppRoutes.registeredRoutes(),
    navType: MainNavigationController.self
)
```

## 最小接入示例

### 1) 定义 Route

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

    static func registeredRoutes() -> [Route] {
        [
            Route(path: AppRoutes.home, type: HomeViewModel.self),
            Route(path: AppRoutes.profile, type: ProfileViewModel.self)
        ]
    }
}
```

### 2) 定义页面 ViewModel

```swift
final class HomeViewModel: RoutableViewModel {
    required init(parameters: [String : Any]?) throws {}

    var routedView: AnyView {
        AnyView(Text("Home"))
    }

    var isRootView: Bool { true }
    var showTabBar: Bool { true }
}
```

### 3) 在 App 启动时初始化

```swift
let router = QuickRouter.start(
    in: window,
    startPath: AppRoutes.home,
    routes: AppRoutes.registeredRoutes(),
    navType: MainNavigationController.self
)
```

之后页面内只需要持有 `router` 并调用：

```swift
router.navigate(to: AppRoutes.profile)
```

## 与你当前工程对齐建议

- 先把 `senzu/senzu/Shared/Router` 替换为该 package 引用
- 第二步再把依赖注入（Resolver）从路由层剥离，放到业务层
- 第三步增加 typed parameters，替代 `[String: Any]`
