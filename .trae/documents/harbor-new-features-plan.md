# Harbor 新功能实施计划

## 功能概述

为 Harbor macOS 菜单栏应用添加两个新功能：
1. **本地服务运行状态视觉指示** — 菜单栏图标根据服务状态动态切换
2. **Popover 退出按钮** — 在 Popover 右上角添加退出按钮

---

## 功能一：本地服务运行状态视觉指示

### 需求描述
- 无本地服务启动时：菜单栏按钮使用 `ferry`（空心渡轮）
- 有本地服务时：菜单栏按钮使用 `ferry.fill`（填充渡轮）

### 当前实现分析
- 图标在 [HarborApp.swift:24](file:///Users/lian/x-xcode/harbor/Sources/harbor/HarborApp.swift#L24) 中一次性设置为 `ferry.fill`，不会随状态变化
- `ProcessMonitorViewModel` 在 [MainView.swift:4](file:///Users/lian/x-xcode/harbor/Sources/harbor/Views/MainView.swift#L4) 中以 `@State` 创建，AppDelegate 无法访问
- ViewModel 每 3 秒轮询刷新进程列表，`processes` 数组实时反映当前服务状态

### 实施方案

#### 步骤 1：将 ViewModel 提升到 AppDelegate 层级

**文件**: `HarborApp.swift`

将 `ProcessMonitorViewModel` 的创建从 `MainView` 移到 `AppDelegate`，使 AppDelegate 能观察进程状态变化并更新菜单栏图标。

```swift
// AppDelegate 新增属性
private let viewModel = ProcessMonitorViewModel()

// applicationDidFinishLaunching 中修改 rootView 创建
let rootView = MainView(viewModel: viewModel)
    .environment(themeSettings)
```

#### 步骤 2：修改 MainView 接受外部传入的 ViewModel

**文件**: `MainView.swift`

将 `@State private var viewModel = ProcessMonitorViewModel()` 改为接受外部参数：

```swift
struct MainView: View {
    var viewModel: ProcessMonitorViewModel
    // ... 其余不变
}
```

#### 步骤 3：在 AppDelegate 中添加图标更新逻辑

**文件**: `HarborApp.swift`

使用 `withObservationTracking` 观察 ViewModel 的 `processes` 变化，动态更新菜单栏图标：

```swift
private func updateStatusBarIcon() {
    let hasActiveServices = viewModel.processes.contains { $0.status == .active }
    let symbolName = hasActiveServices ? "ferry.fill" : "ferry"
    statusItem.button?.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Harbor")
}

private func observeViewModel() {
    withObservationTracking {
        _ = viewModel.processes
    } onChange: {
        DispatchQueue.main.async { [weak self] in
            self?.updateStatusBarIcon()
            self?.observeViewModel()
        }
    }
}
```

在 `applicationDidFinishLaunching` 末尾调用 `updateStatusBarIcon()` 和 `observeViewModel()`。

### 判断逻辑
- 使用 `viewModel.processes.contains { $0.status == .active }` 判断是否有活跃服务
- 与 MainView header 中 `activeCount` 的计算逻辑保持一致（[MainView.swift:36-38](file:///Users/lian/x-xcode/harbor/Sources/harbor/Views/MainView.swift#L36-L38)）

---

## 功能二：菜单栏 Popover 页面退出按钮

### 需求描述
- 在 Popover 页面右上角添加退出按钮
- 与现有 UI 风格一致
- 点击触发应用正常退出流程

### 当前实现分析
- Header 区域布局（[MainView.swift:65-155](file:///Users/lian/x-xcode/harbor/Sources/harbor/Views/MainView.swift#L65-L155)）：
  ```
  [Harbor 标题 + 活跃数] [Spacer] [搜索框] [主题按钮] [刷新按钮]
  ```
- 现有按钮样式：28x28 圆角矩形，`surfaceRaised` 背景，`border` 描边，12pt SF Symbol
- 现有退出方式：右键菜单栏图标 → "Quit Harbor"（[HarborApp.swift:36](file:///Users/lian/x-xcode/harbor/Sources/harbor/HarborApp.swift#L36)）

### 实施方案

#### 步骤 1：在 MainView header 中添加退出按钮

**文件**: `MainView.swift`

在刷新按钮之后、header HStack 末尾添加退出按钮，使用 `power` SF Symbol：

```swift
Button(action: { NSApplication.shared.terminate(nil) }) {
    Image(systemName: "power")
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(theme.textSecondary)
        .frame(width: 28, height: 28)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(theme.surfaceRaised)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(theme.border.opacity(0.5), lineWidth: 0.5)
        )
}
.buttonStyle(.plain)
.help("Quit Harbor")
```

### 设计决策
- **SF Symbol**: 使用 `power`（电源符号），这是退出/关闭的通用视觉语言
- **位置**: 放在刷新按钮右侧，即 header 最右端，符合"右上角"需求
- **样式**: 完全复用现有按钮的 28x28 圆角矩形样式，保持视觉一致性
- **交互**: 点击直接调用 `NSApplication.shared.terminate(nil)`，与现有右键菜单退出逻辑一致
- **Tooltip**: "Quit Harbor"，与右键菜单文案一致

---

## 修改文件清单

| 文件 | 修改内容 |
|------|----------|
| `Sources/harbor/HarborApp.swift` | 新增 ViewModel 属性；修改 rootView 创建方式传入 ViewModel；新增 `updateStatusBarIcon()` 和 `observeViewModel()` 方法；在启动时调用 |
| `Sources/harbor/Views/MainView.swift` | 将 `@State private var viewModel` 改为 `var viewModel` 参数；在 header 中添加退出按钮 |

共修改 2 个文件，无新增文件。

---

## 边界情况处理

1. **应用启动时**：ViewModel 的 `processes` 为空数组，`hasActiveServices` 为 `false`，图标显示 `ferry`（空心）
2. **所有服务终止后**：`processes` 中无 `.active` 状态进程，图标切换回 `ferry`
3. **快速状态变化**：`withObservationTracking` 在主线程异步更新，避免竞态条件
4. **Popover 已关闭时图标仍更新**：图标更新不依赖 Popover 状态，始终响应
5. **退出按钮点击**：直接调用 `NSApplication.shared.terminate(nil)`，触发标准退出流程
6. **不同屏幕分辨率**：SF Symbol 自动适配分辨率，28x28 按钮尺寸在各分辨率下均可点击

---

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 0 | — | — |
| Codex Review | `/codex review` | Independent 2nd opinion | 0 | — | — |
| Eng Review | `/plan-eng-review` | Architecture & tests (required) | 0 | — | — |
| Design Review | `/plan-design-review` | UI/UX gaps | 0 | — | — |
| DX Review | `/plan-devex-review` | Developer experience gaps | 0 | — | — |

**VERDICT:** Pending review
