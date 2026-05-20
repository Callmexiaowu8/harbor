# Tasks

- [x] Task 1: 扩展 ProcessMonitorViewModel 收藏管理方法
  - [x] SubTask 1.1: 添加 `updateFavorite(_:)` 方法，根据 id 查找并替换收藏项，持久化保存
  - [x] SubTask 1.2: 添加 `addFavoriteFromProcess(_:)` 方法，从 ServerProcess 提取信息创建 FavoriteService 并添加到列表

- [x] Task 2: 重构 AddServiceView 支持编辑模式
  - [x] SubTask 2.1: 添加可选的 `editingFavorite: FavoriteService?` 参数
  - [x] SubTask 2.2: 添加 `onEdit: (FavoriteService) -> Void` 回调
  - [x] SubTask 2.3: 编辑模式下预填充所有字段（name, workingDirectory, startCommand, port）
  - [x] SubTask 2.4: 编辑模式下标题改为"Edit Service"，确认按钮改为"Save"
  - [x] SubTask 2.5: 编辑模式下工作目录字段设为只读
  - [x] SubTask 2.6: 保存时根据模式调用 `onAdd` 或 `onEdit`，编辑时保持原 id 和 createdAt

- [x] Task 3: 修改 ServiceListRowView 添加星号和编辑交互
  - [x] SubTask 3.1: `runningOnly` 状态图标从 `StatusIndicatorView` 改为可点击的 `star` 轮廓图标
  - [x] SubTask 3.2: 添加 `onFavorite` 回调参数，星号点击时触发
  - [x] SubTask 3.3: 添加 `onEdit` 回调参数
  - [x] SubTask 3.4: 星号轮廓图标添加悬停变色效果（accent 色）
  - [x] SubTask 3.5: `favoriteRunning` 操作区添加编辑按钮（`pencil.circle`），位于打开和终止按钮之间
  - [x] SubTask 3.6: `favoriteIdle` 操作区添加编辑按钮（`pencil.circle`），位于启动和移除按钮之间
  - [x] SubTask 3.7: 编辑按钮添加悬停变色效果和 tooltip "Edit service"

- [x] Task 4: 修改 MainView 支持编辑和收藏流程
  - [x] SubTask 4.1: 添加 `@State private var editingFavorite: FavoriteService?` 状态
  - [x] SubTask 4.2: 添加编辑模式 sheet，绑定 `editingFavorite`，使用 AddServiceView 编辑模式
  - [x] SubTask 4.3: ServiceListRowView 的 `onFavorite` 回调：调用 `addFavoriteFromProcess` 创建收藏，然后设置 `editingFavorite` 弹出编辑 sheet
  - [x] SubTask 4.4: ServiceListRowView 的 `onEdit` 回调：设置 `editingFavorite` 弹出编辑 sheet
  - [x] SubTask 4.5: 编辑 sheet 保存回调调用 `viewModel.updateFavorite`

- [x] Task 5: 构建验证
  - [x] SubTask 5.1: `xcodebuild` 编译通过
  - [x] SubTask 5.2: 检查无编译警告

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 1]
- [Task 4] depends on [Task 1, Task 2, Task 3]
- [Task 5] depends on [Task 4]
