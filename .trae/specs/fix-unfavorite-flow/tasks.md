# Tasks

- [ ] Task 1: 重构确认流程状态为枚举类型
  - [ ] SubTask 1.1: 定义 `ConfirmKind` 枚举（`.terminate`, `.unfavorite`）
  - [ ] SubTask 1.2: 替换 `confirming: Bool` + `isUnfavoriteConfirm: Bool` 为 `confirmKind: ConfirmKind?`
  - [ ] SubTask 1.3: 星号点击设置 `confirmKind = .unfavorite`
  - [ ] SubTask 1.4: 终止按钮点击设置 `confirmKind = .terminate`
  - [ ] SubTask 1.5: Cancel 和确认操作设置 `confirmKind = nil`

- [ ] Task 2: 修复确认栏差异化展示
  - [ ] SubTask 2.1: `confirmMessage` 根据 `confirmKind` 返回不同文案
  - [ ] SubTask 2.2: `confirmActionLabel` 根据 `confirmKind` 返回 "Terminate" 或 "Remove"
  - [ ] SubTask 2.3: 确认按钮颜色：`.terminate` 用 `theme.danger`，`.unfavorite` 用 `theme.accent`
  - [ ] SubTask 2.4: 确认栏背景色：`.terminate` 用 `theme.danger.opacity(0.06)`，`.unfavorite` 用 `theme.accent.opacity(0.06)`
  - [ ] SubTask 2.5: 确认栏边框色：`.terminate` 用 `theme.danger.opacity(0.3)`，`.unfavorite` 用 `theme.accent.opacity(0.3)`

- [ ] Task 3: 修复确认回调严格隔离
  - [ ] SubTask 3.1: 确认按钮回调根据 `confirmKind` 严格调用对应回调，不使用 `item.isRunning` 判断
  - [ ] SubTask 3.2: `.terminate` → 仅调用 `onTerminate()`
  - [ ] SubTask 3.3: `.unfavorite` → 仅调用 `onRemoveFavorite()`

- [ ] Task 4: 构建验证
  - [ ] SubTask 4.1: xcodebuild 编译通过
  - [ ] SubTask 4.2: 无编译警告

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 1]
- [Task 4] depends on [Task 1, Task 2, Task 3]
