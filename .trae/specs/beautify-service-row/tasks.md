# Tasks

- [ ] Task 1: 精简 ServiceListRowView 的 detailLine 信息展示
  - [ ] SubTask 1.1: 重构 detailLine，favoriteRunning 显示端口徽章 + PID
  - [ ] SubTask 1.2: favoriteIdle 显示启动命令（不显示工作目录和进程信息）
  - [ ] SubTask 1.3: runningOnly 显示端口徽章 + PID
  - [ ] SubTask 1.4: 移除 detailLine 中的工作目录、完整进程名、启动命令（运行中）等冗余信息

- [ ] Task 2: 实现星号取消收藏交互
  - [ ] SubTask 2.1: favoriteRunning 和 favoriteIdle 的 star.fill 改为可点击 Button，点击触发取消收藏确认
  - [ ] SubTask 2.2: 填充星标添加悬停反馈（透明度变化）和 tooltip "Remove from favorites"
  - [ ] SubTask 2.3: 新增 `onUnfavorite` 回调参数（或复用现有 onRemoveFavorite）
  - [ ] SubTask 2.4: 取消收藏确认栏与终止确认栏共用 confirming 状态，通过判断区分

- [ ] Task 3: 精简操作区域按钮
  - [ ] SubTask 3.1: idleFavoriteButtons 移除"移除收藏"按钮（minus.circle），保留启动 + 编辑
  - [ ] SubTask 3.2: runningActionButtons 不变（打开 + 编辑 + 终止）

- [ ] Task 4: 添加 tooltip 完整信息
  - [ ] SubTask 4.1: 整行 HStack 添加 .help() 或 overlay tooltip，显示被隐藏的详细信息

- [ ] Task 5: 构建验证
  - [ ] SubTask 5.1: xcodebuild 编译通过
  - [ ] SubTask 5.2: 无编译警告

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 1]
- [Task 5] depends on [Task 1, Task 2, Task 3, Task 4]
