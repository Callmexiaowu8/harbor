# 修复星号取消收藏流程 Bug Spec

## Why
当前点击星号取消收藏运行中的服务时，确认栏按钮显示"Terminate"而非"Remove"，且确认栏使用红色危险样式，严重误导用户以为会终止服务。更严重的是，`isUnfavoriteConfirm` 状态与确认回调之间存在耦合不一致，可能在 SwiftUI 视图重建时导致状态丢失，实际触发 `onTerminate()` 而非 `onRemoveFavorite()`。

## What Changes
- 修复 `confirmActionLabel`，根据 `isUnfavoriteConfirm` 显示正确的按钮文案
- 将确认流程从单一 `confirming` 状态重构为枚举类型，彻底隔离"终止进程"和"取消收藏"两种确认场景
- 取消收藏确认栏使用非危险色样式（accent 色而非 danger 色）
- 确保取消收藏操作绝不调用 `onTerminate()`

## Impact
- Affected code: `ServiceListRowView.swift`
- No new files needed

## ADDED Requirements

### Requirement: 确认流程枚举类型
系统 SHALL 使用枚举类型替代当前的 `confirming: Bool` + `isUnfavoriteConfirm: Bool` 双状态组合，彻底消除状态不一致风险。

```swift
enum ConfirmKind {
    case terminate    // 终止进程
    case unfavorite   // 取消收藏
}
@State private var confirmKind: ConfirmKind? = nil  // nil = 无确认栏
```

#### Scenario: 显示确认栏
- **WHEN** 用户点击终止按钮
- **THEN** `confirmKind = .terminate`
- **WHEN** 用户点击星号取消收藏
- **THEN** `confirmKind = .unfavorite`

#### Scenario: 隐藏确认栏
- **WHEN** 用户点击 Cancel 或完成确认操作
- **THEN** `confirmKind = nil`

### Requirement: 确认栏差异化展示
系统 SHALL 根据确认类型显示不同的文案、按钮标签和颜色：

| 确认类型 | 消息 | 按钮标签 | 按钮颜色 | 背景色 |
|---------|------|---------|---------|--------|
| `.terminate` | "Stop {name} on port {port}?" | "Terminate" | danger (红) | danger.opacity(0.06) |
| `.unfavorite` | "Remove {name} from favorites?" | "Remove" | accent (主题色) | accent.opacity(0.06) |

#### Scenario: 取消收藏确认栏样式
- **WHEN** 用户通过星号触发取消收藏确认
- **THEN** 确认栏背景为 accent 透明色，确认按钮为 accent 色填充，标签为"Remove"

#### Scenario: 终止进程确认栏样式
- **WHEN** 用户通过终止按钮触发终止确认
- **THEN** 确认栏背景为 danger 透明色，确认按钮为 danger 色填充，标签为"Terminate"

### Requirement: 确认回调严格隔离
系统 SHALL 确保取消收藏确认绝不调用 `onTerminate()`，终止进程确认绝不调用 `onRemoveFavorite()`。

#### Scenario: 取消收藏确认回调
- **WHEN** `confirmKind == .unfavorite` 且用户点击确认按钮
- **THEN** 仅调用 `onRemoveFavorite()`，绝不调用 `onTerminate()`

#### Scenario: 终止进程确认回调
- **WHEN** `confirmKind == .terminate` 且用户点击确认按钮
- **THEN** 仅调用 `onTerminate()`，绝不调用 `onRemoveFavorite()`

## MODIFIED Requirements

### Requirement: 确认流程状态管理
原：`@State private var confirming = false` + `@State private var isUnfavoriteConfirm = false`
现：`@State private var confirmKind: ConfirmKind? = nil`

### Requirement: 确认栏触发方式
原：终止按钮和星号分别设置 `isUnfavoriteConfirm` 和 `confirming`
现：终止按钮设置 `confirmKind = .terminate`，星号设置 `confirmKind = .unfavorite`

## REMOVED Requirements
无
