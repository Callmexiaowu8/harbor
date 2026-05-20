# 收藏本地服务功能 Spec

## Why
当前 Harbor 只能被动发现和终止运行中的本地服务，用户无法从应用内主动启动服务。用户需要手动在终端中 cd 到项目目录并输入启动命令，这个流程可以由 Harbor 简化——收藏常用服务的启动配置，一键在终端中拉起。

## What Changes
- 新增 `FavoriteService` 数据模型，存储服务的启动配置（名称、工作目录、启动命令、端口）
- 新增 `ServiceLaunchService`，通过 AppleScript 在 Terminal.app 中执行启动命令
- 新增 `ProjectManifestService`，从项目清单文件自动检测可用启动命令
- 扩展 `PersistenceService`，支持收藏服务的持久化存储
- 扩展 `ProcessMonitorViewModel`，管理收藏列表、启动服务、匹配运行状态
- 新增 `AddServiceView`，手动添加服务配置的界面（目录选择、命令检测/输入）
- 新增 `ServiceListRowView`，替代原有 `ProcessRowView`，支持收藏和运行状态的差异化展示
- 修改 `MainView`，混合显示收藏服务和运行中服务
- 修改 `ServerProcess`，添加 `workingDirectory` 字段用于匹配收藏服务
- 修改 `ProcessDiscoveryService`，获取进程工作目录用于收藏匹配
- 清理 `ProcessRowView`（已成为死代码）

## Impact
- Affected code: `ServerProcess.swift`, `PersistenceService.swift`, `ProcessMonitorViewModel.swift`, `MainView.swift`, `ProcessDiscoveryService.swift`, `HarborApp.swift`
- New files: `FavoriteService.swift`, `ServiceLaunchService.swift`, `ProjectManifestService.swift`, `AddServiceView.swift`, `ServiceListRowView.swift`
- Removed files: `ProcessRowView.swift`（死代码清理）
- Project file: `project.pbxproj` 需添加新文件引用、移除 ProcessRowView 引用

## ADDED Requirements

### Requirement: Favorite Service Data Model
系统 SHALL 提供 `FavoriteService` 数据模型，包含以下字段：
- `id`: UUID 唯一标识
- `name`: 显示名称
- `workingDirectory`: 项目工作目录路径
- `startCommand`: 启动命令字符串（如 `npm run dev`）
- `port`: 期望监听端口（可选，用于与运行中服务匹配）
- `createdAt`: 创建时间

模型 SHALL 遵循 `Identifiable`, `Hashable`, `Codable`, `Sendable` 协议。

#### Scenario: 创建收藏服务
- **WHEN** 用户填写名称、工作目录、启动命令后确认添加
- **THEN** 系统创建 FavoriteService 实例并持久化存储

### Requirement: 手动添加服务配置
系统 SHALL 提供手动添加收藏服务的界面，包含：
- 工作目录选择器（NSOpenPanel 目录选择）
- 自动检测：选择目录后自动扫描项目清单文件，提取可用启动命令供选择
- 启动命令输入框：支持手动输入自定义命令
- 名称输入框：默认使用目录名
- 端口输入框（可选）
- 表单验证：名称、工作目录、启动命令为必填项

#### Scenario: 通过目录选择添加服务
- **WHEN** 用户点击添加按钮，选择工作目录，指定启动命令和名称
- **THEN** 系统创建收藏服务并添加到收藏列表

#### Scenario: 自动检测启动命令
- **WHEN** 用户选择了工作目录
- **THEN** 系统自动扫描目录下的 package.json / Cargo.toml / go.mod / pyproject.toml / Makefile / mix.exs 等清单文件，提取可用命令（如 package.json 的 scripts、Makefile 的 targets），展示供用户选择

#### Scenario: 目录无清单文件
- **WHEN** 用户选择的目录不包含任何已知清单文件
- **THEN** 自动检测结果为空，用户仍可手动输入启动命令

#### Scenario: 选择检测到的命令
- **WHEN** 用户点击某个检测到的命令
- **THEN** 启动命令输入框自动填充该命令；若名称为空则自动填充目录名

### Requirement: 一键启动服务
系统 SHALL 支持通过 AppleScript 在 Terminal.app 中启动收藏的服务。

#### Scenario: 启动未运行的服务
- **WHEN** 用户点击收藏服务的启动按钮
- **THEN** 系统通过 AppleScript 打开 Terminal.app，在新标签页中执行 `cd {workingDirectory} && {startCommand}`，进程独立于 Harbor 运行

#### Scenario: 启动已运行的服务
- **WHEN** 收藏服务已处于运行状态
- **THEN** 该收藏项显示终止和打开浏览器按钮（而非启动按钮），不提供启动操作

#### Scenario: Terminal.app 未安装
- **WHEN** 系统尝试启动服务但 Terminal.app 不可用
- **THEN** 在主界面错误区域显示错误提示信息

### Requirement: 收藏服务与运行状态匹配
系统 SHALL 将收藏服务与 lsof 发现的运行中进程进行匹配，匹配规则：
1. 收藏服务的 `workingDirectory` 与运行进程的 CWD 一致
2. 或收藏服务的 `port` 与运行进程的端口一致

匹配依赖 `ServerProcess.workingDirectory` 字段，该字段由 `ProcessDiscoveryService` 在发现进程时通过 `lsof` 获取进程 CWD 填充。

#### Scenario: 收藏服务正在运行
- **WHEN** 收藏服务匹配到一个运行中的进程
- **THEN** 该收藏项显示为运行状态，展示进程信息（PID、端口），提供终止和打开浏览器按钮

#### Scenario: 收藏服务未运行
- **WHEN** 收藏服务未匹配到任何运行中的进程
- **THEN** 该收藏项显示为未运行状态，提供启动按钮和移除收藏按钮

#### Scenario: 运行中的服务未被收藏
- **WHEN** 发现的运行进程不匹配任何收藏服务
- **THEN** 该进程照常显示，不带星标图标

### Requirement: 混合显示收藏与运行服务
系统 SHALL 在同一列表中混合显示收藏服务和未收藏的运行中服务：
- 收藏服务（无论运行与否）始终显示，带星标图标（`star.fill`）
- 未收藏的运行中服务正常显示，不带星标
- 列表排序：收藏服务在前，未收藏运行服务在后
- 未运行的收藏服务显示启动按钮和移除收藏按钮
- 运行中的收藏服务显示终止按钮和打开浏览器按钮
- 未收藏的运行中服务显示终止按钮和打开浏览器按钮

#### Scenario: 列表包含收藏和未收藏服务
- **WHEN** 用户有 2 个收藏服务（1 个运行中、1 个未运行）和 1 个未收藏的运行服务
- **THEN** 列表显示 3 项：运行中的收藏服务（星标+终止+打开）、未运行的收藏服务（星标+启动+移除）、未收藏的运行服务（终止+打开）

#### Scenario: 删除收藏服务
- **WHEN** 用户从收藏服务中移除一个项
- **THEN** 该项从收藏列表中移除；如果对应服务仍在运行，它仍显示在未收藏运行服务区域

### Requirement: 移除收藏确认
系统 SHALL 在移除收藏服务前显示确认栏，防止误操作。

#### Scenario: 确认移除收藏
- **WHEN** 用户点击移除收藏按钮
- **THEN** 在该行内展开确认栏，显示"Remove {name} from favorites?"提示和 Cancel/Remove 按钮
- **WHEN** 用户点击 Remove
- **THEN** 执行移除操作
- **WHEN** 用户点击 Cancel
- **THEN** 收起确认栏，不做任何操作

### Requirement: 终止进程确认
系统 SHALL 在终止运行中进程前显示确认栏，防止误操作。

#### Scenario: 确认终止进程
- **WHEN** 用户点击终止按钮
- **THEN** 在该行内展开确认栏，显示"Stop {name} on port {port}?"提示和 Cancel/Terminate 按钮
- **WHEN** 用户点击 Terminate
- **THEN** 执行终止操作
- **WHEN** 用户点击 Cancel
- **THEN** 收起确认栏，不做任何操作

### Requirement: 收藏服务持久化
系统 SHALL 将收藏服务列表持久化到 UserDefaults，应用重启后恢复。

#### Scenario: 应用重启后恢复收藏
- **WHEN** 应用重新启动
- **THEN** 收藏服务列表从 UserDefaults 恢复，与退出前一致

### Requirement: ServiceListRowView 替代 ProcessRowView
系统 SHALL 使用新的 `ServiceListRowView` 替代原有 `ProcessRowView`，支持三种服务项类型的差异化展示：
- `favoriteRunning`：星标图标 + 服务名 + 启动命令 + 工作目录 + 进程信息 + 终止/打开按钮
- `favoriteIdle`：星标图标 + 服务名 + 启动命令 + 工作目录 + 启动/移除按钮
- `runningOnly`：状态指示器 + 进程名 + 进程信息 + 终止/打开按钮

原有 `ProcessRowView` SHALL 被移除。

### Requirement: 搜索功能覆盖收藏服务
系统 SHALL 确保搜索过滤功能同时覆盖收藏服务和运行中服务，支持按名称、端口、PID、命令等关键词过滤。

## MODIFIED Requirements

### Requirement: MainView 列表内容
原：仅显示 lsof 发现的运行中进程列表
现：混合显示收藏服务和运行中进程，收藏服务带星标图标，未运行收藏项显示启动按钮；Header 新增添加收藏按钮（`plus` 图标）

### Requirement: ServerProcess 数据模型
原：不包含工作目录信息
现：新增 `workingDirectory: String?` 字段，由 ProcessDiscoveryService 在发现进程时填充，用于与收藏服务匹配

### Requirement: ProcessDiscoveryService
原：仅获取进程 PID、PGID、名称、命令、端口
现：额外获取进程工作目录（CWD），通过 `lsof` 的 `cwd` 信息获取，填充到 `ServerProcess.workingDirectory`

### Requirement: Header 操作区
原：标题 + 搜索 + 主题 + 刷新 + 退出
现：标题 + 搜索 + 主题 + 添加收藏按钮 + 刷新 + 退出

## REMOVED Requirements

### Requirement: ProcessRowView
**Reason**: 被 `ServiceListRowView` 替代，后者支持收藏和运行状态的差异化展示
**Migration**: 删除 `ProcessRowView.swift` 文件，从 Xcode 项目引用中移除

## Future Enhancements (Out of Scope)
以下功能不在当前版本范围内，但可作为后续迭代考虑：
- 编辑已收藏的服务配置
- 从运行中服务直接添加到收藏
- 重复收藏检测（相同工作目录+命令时提示）
- 终端选择（支持 iTerm2、Warp 等）
- 启动命令环境变量配置
- 收藏服务拖拽排序
