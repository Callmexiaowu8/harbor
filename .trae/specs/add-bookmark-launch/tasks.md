# Tasks

- [x] Task 1: 新增 BookmarkedService 数据模型
  - [x] 创建 `Sources/harbor/Models/BookmarkedService.swift`
  - [x] 定义 `BookmarkedService` 结构体：id(UUID), name, command, arguments, workingDirectory, port(可选), launchMode(.terminal/.background), createdAt
  - [x] 定义 `LaunchMode` 枚举：terminal, background
  - [x] 遵循 Identifiable, Hashable, Codable, Sendable 协议

- [x] Task 2: 扩展 ServerProcess 模型
  - [x] 在 `ServerProcess.swift` 中新增 `fullCommand: String?` 和 `workingDirectory: String?` 可选字段
  - [x] 更新 init 方法，支持新字段
  - [x] 保持向后兼容（Codable 解码旧数据时新字段为 nil）

- [x] Task 3: 扩展 ProcessDiscoveryService 获取完整命令行和工作目录
  - [x] 新增 `getFullCommand(pid:)` 方法，通过 `ps -p PID -o command=` 获取完整命令行
  - [x] 修改 `parseLsofOutput` 中创建 `ServerProcess` 时，异步获取 fullCommand 和 workingDirectory
  - [x] 复用现有 `getProcessCwd` 方法获取工作目录

- [x] Task 4: 新增 ProcessLaunchService
  - [x] 创建 `Sources/harbor/Services/ProcessLaunchService.swift`
  - [x] 实现 `launchInTerminal(command:workingDirectory:terminalBundleId:)` 方法：通过 `open -a Terminal.app` 或 AppleScript 在指定终端中执行命令
  - [x] 实现 `launchInBackground(command:workingDirectory:bookmarkId:)` 方法：通过 `Process()` 后台启动，stdout/stderr 重定向到日志文件
  - [x] 日志文件路径：`~/Library/Logs/Harbor/{bookmarkId}.log`，自动创建目录
  - [x] 实现 `openLogFile(bookmarkId:)` 方法：用 `NSWorkspace.shared.open` 打开日志文件

- [x] Task 5: 扩展 PersistenceService 支持收藏持久化
  - [x] 新增 `loadBookmarks() -> [BookmarkedService]` 方法
  - [x] 新增 `saveBookmarks(_:)` 方法
  - [x] 新增 UserDefaults key `harbor.bookmarks`
  - [x] 新增终端偏好存取：`loadTerminalPreference() / saveTerminalPreference()`

- [x] Task 6: 扩展 ProcessMonitorViewModel
  - [x] 新增 `bookmarks: [BookmarkedService]` 属性
  - [x] 新增 `terminalPreference: String` 属性（终端 Bundle ID）
  - [x] 实现 `addBookmark(from process: ServerProcess)` — 从运行中服务创建收藏
  - [x] 实现 `addBookmark(_ bookmark: BookmarkedService)` — 手动添加收藏
  - [x] 实现 `removeBookmark(id:)` — 删除收藏
  - [x] 实现 `updateBookmark(_:)` — 更新收藏配置
  - [x] 实现 `isBookmarked(processId:) -> Bool` — 判断进程是否已收藏
  - [x] 实现 `launchService(_ bookmark: BookmarkedService)` — 根据启动模式调用 ProcessLaunchService
  - [x] 实现 `openLogFile(for bookmark: BookmarkedService)` — 打开日志文件
  - [x] 修改 `refresh()` 逻辑：合并运行中进程和已收藏服务，建立关联（通过 command+port 或 workingDirectory+port 匹配）
  - [x] 新增计算属性 `displayItems` — 合并排序后的展示列表（运行中在上，已收藏未运行在下）

- [x] Task 7: 新增 BookmarkedServiceRowView
  - [x] 创建 `Sources/harbor/Views/BookmarkedServiceRowView.swift`
  - [x] 灰色/暗淡样式展示已收藏但未运行的服务
  - [x] 显示：名称、命令摘要、工作目录、端口（如有）
  - [x] 操作按钮：启动（play 按钮）、查看日志（仅后台启动模式）、编辑、删除
  - [x] 复用 ProcessRowView 的圆角矩形卡片样式

- [x] Task 8: 新增 AddBookmarkView
  - [x] 创建 `Sources/harbor/Views/AddBookmarkView.swift`
  - [x] 表单字段：显示名称、启动命令、工作目录（带文件夹选择器）、预期端口（可选）、启动模式选择
  - [x] 保存/取消按钮
  - [x] 支持新建和编辑两种模式
  - [x] 以 Sheet 形式弹出

- [x] Task 9: 扩展 ProcessRowView 增加收藏按钮
  - [x] 在操作按钮区域新增星标按钮（star / star.fill）
  - [x] 点击切换收藏状态，调用 ViewModel 的 addBookmark/removeBookmark
  - [x] 已收藏状态显示填充星标 + accent 色

- [x] Task 10: 扩展 MainView 混合展示
  - [x] header 新增 "+" 按钮用于手动添加收藏
  - [x] 进程列表区域改为展示 `displayItems`（运行中 + 已收藏未运行）
  - [x] 运行中的服务使用 ProcessRowView，已收藏未运行的使用 BookmarkedServiceRowView
  - [x] 新增 AddBookmarkView 的 Sheet 绑定状态

- [x] Task 11: 新增终端偏好设置 UI
  - [x] 在 header 或右键菜单中添加终端选择入口
  - [x] 提供下拉菜单选择终端应用：Terminal.app、iTerm2、Warp、Alacritty、Kitty
  - [x] 选择后持久化到 UserDefaults

# Task Dependencies
- Task 2 depends on Task 1 (BookmarkedService 模型定义)
- Task 3 depends on Task 2 (ServerProcess 扩展)
- Task 6 depends on Task 1, Task 4, Task 5 (ViewModel 需要所有服务和模型)
- Task 7 depends on Task 1 (BookmarkedServiceRowView 需要 BookmarkedService 模型)
- Task 8 depends on Task 1 (AddBookmarkView 需要 BookmarkedService 模型)
- Task 9 depends on Task 6 (ProcessRowView 需要调用 ViewModel 方法)
- Task 10 depends on Task 6, Task 7, Task 8, Task 9 (MainView 整合所有子视图)
- Task 11 depends on Task 5 (终端偏好需要 PersistenceService)
