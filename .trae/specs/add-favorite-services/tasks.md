# Tasks

- [x] Task 1: 创建 FavoriteService 数据模型
  - [x] SubTask 1.1: 创建 `Sources/harbor/Models/FavoriteService.swift`，定义 FavoriteService 结构体（id, name, workingDirectory, startCommand, port, createdAt）
  - [x] SubTask 1.2: 确保 FavoriteService 遵循 Identifiable, Hashable, Codable, Sendable 协议

- [x] Task 2: 扩展 PersistenceService 支持收藏服务持久化
  - [x] SubTask 2.1: 添加 `favoriteServicesKey` 常量
  - [x] SubTask 2.2: 添加 `loadFavoriteServices()` 方法
  - [x] SubTask 2.3: 添加 `saveFavoriteServices(_:)` 方法

- [x] Task 3: 创建 ServiceLaunchService
  - [x] SubTask 3.1: 创建 `Sources/harbor/Services/ServiceLaunchService.swift`
  - [x] SubTask 3.2: 实现 `launch(workingDirectory:startCommand:)` 方法，通过 NSAppleScript 在 Terminal.app 中执行 `cd {dir} && {cmd}`
  - [x] SubTask 3.3: 添加错误处理（Terminal 不可用、脚本执行失败等）

- [x] Task 4: 创建 ProjectManifestService
  - [x] SubTask 4.1: 创建 `Sources/harbor/Services/ProjectManifestService.swift`
  - [x] SubTask 4.2: 实现 `detectCommands(inDirectory:)` 方法，扫描 package.json / Cargo.toml / Makefile / pyproject.toml / go.mod / mix.exs
  - [x] SubTask 4.3: 实现 package.json scripts 提取
  - [x] SubTask 4.4: 实现 Makefile targets 提取
  - [x] SubTask 4.5: 实现 Cargo.toml / pyproject.toml / go.mod / mix.exs 基本检测

- [x] Task 5: 扩展 ProcessMonitorViewModel
  - [x] SubTask 5.1: 添加 `favoriteServices: [FavoriteService]` 属性，从 PersistenceService 加载初始化
  - [x] SubTask 5.2: 添加 `addFavorite(_:)` 方法
  - [x] SubTask 5.3: 添加 `removeFavorite(_:)` 方法
  - [x] SubTask 5.4: 添加 `launchService(_:)` 方法，调用 ServiceLaunchService
  - [x] SubTask 5.5: 添加 `ServiceListItem` 和计算属性 `serviceListItems`，将收藏服务与运行中进程匹配，生成混合列表数据
  - [x] SubTask 5.6: 在 `refresh()` 中更新收藏服务的运行状态匹配

- [x] Task 6: 创建 AddServiceView
  - [x] SubTask 6.1: 创建 `Sources/harbor/Views/AddServiceView.swift`
  - [x] SubTask 6.2: 实现工作目录选择（NSOpenPanel）
  - [x] SubTask 6.3: 实现自动检测，选择目录后自动调用 ProjectManifestService
  - [x] SubTask 6.4: 实现启动命令输入/选择（检测命令点击自动填充）
  - [x] SubTask 6.5: 实现名称和端口输入
  - [x] SubTask 6.6: 实现确认添加逻辑，调用 ViewModel 的 addFavorite

- [x] Task 7: 修改 MainView 混合显示
  - [x] SubTask 7.1: 在 header 添加「添加收藏」按钮（plus icon）
  - [x] SubTask 7.2: 添加 AddServiceView 的 sheet 弹出状态
  - [x] SubTask 7.3: 修改列表数据源，使用 ViewModel 的混合列表数据
  - [x] SubTask 7.4: 列表排序：收藏在前，未收藏运行服务在后

- [x] Task 8: 创建 ServiceListRowView 替代 ProcessRowView
  - [x] SubTask 8.1: 创建 `Sources/harbor/Views/ServiceListRowView.swift`
  - [x] SubTask 8.2: 实现三种行类型（favoriteRunning / favoriteIdle / runningOnly）的差异化展示
  - [x] SubTask 8.3: 收藏项显示星标图标（star.fill）
  - [x] SubTask 8.4: 未运行收藏项显示启动按钮和移除收藏按钮
  - [x] SubTask 8.5: 运行中收藏项显示终止+打开浏览器按钮
  - [x] SubTask 8.6: 实现终止进程和移除收藏的确认栏

- [x] Task 9: 修改 ServerProcess 和 ProcessDiscoveryService
  - [x] SubTask 9.1: ServerProcess 添加 `workingDirectory: String?` 字段
  - [x] SubTask 9.2: ProcessDiscoveryService 在发现进程时获取 CWD 并填充

- [x] Task 10: 构建验证
  - [x] SubTask 10.1: `swift build` 编译通过
  - [x] SubTask 10.2: 检查无编译警告

- [x] Task 11: 清理 ProcessRowView 死代码
  - [x] SubTask 11.1: 删除 `Sources/harbor/Views/ProcessRowView.swift` 文件
  - [x] SubTask 11.2: 从 `project.pbxproj` 中移除 ProcessRowView 的 PBXFileReference、PBXBuildFile 和 PBXGroup 引用
  - [x] SubTask 11.3: 确认 `swift build` 编译通过

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 5] depends on [Task 1, Task 2, Task 3]
- [Task 6] depends on [Task 4, Task 5]
- [Task 7] depends on [Task 5, Task 6]
- [Task 8] depends on [Task 5]
- [Task 9] depends on [Task 5]
- [Task 10] depends on [Task 7, Task 8, Task 9]
- [Task 11] depends on [Task 8, Task 10]
