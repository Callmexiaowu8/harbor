# 后台启动服务 Spec

## Why
当前收藏服务仅支持通过 Terminal.app 启动，用户必须保持终端窗口打开。后台启动功能让服务在后台静默运行，日志重定向到文件，无需终端窗口，更适合长期运行的本地服务。

## What Changes
- 扩展 `ServiceLaunchService`，新增 `launchInBackground` 方法，使用 `Process` (NSTask) 后台启动
- 修改 `ServiceListRowView`，`idleFavoriteButtons` 区域显示两个启动按钮（终端启动 + 后台启动）
- 修改 `ProcessMonitorViewModel`，添加 `launchServiceInBackground` 方法
- 日志保存到 `~/.harbor/logs/{service-name}-{timestamp}.log`
- 后台启动的进程仍通过 lsof 被自动发现，无需额外进程管理

## Impact
- Affected code: `ServiceLaunchService.swift`, `ServiceListRowView.swift`, `ProcessMonitorViewModel.swift`, `MainView.swift`
- No new files needed

## ADDED Requirements

### Requirement: 后台启动服务
系统 SHALL 支持通过 `Process` (Foundation) 后台启动收藏服务，进程独立于 Harbor 运行。

#### 技术实现
- 使用 `Process` 类创建子进程
- `currentDirectoryURL` 设置为服务的 `workingDirectory`（确保命令在正确目录下执行）
- `stdout` 和 `stderr` 重定向到日志文件
- 进程以新进程组启动（`process.isSProcess = true`），与 Harbor 进程分离
- 使用 `/bin/zsh -c "{command}"` 执行启动命令，支持管道等 shell 特性

#### Scenario: 后台启动未运行的服务
- **WHEN** 用户点击后台启动按钮
- **THEN** 系统使用 `Process` 在后台启动服务，`currentDirectoryURL` 设为 `workingDirectory`
- **AND** stdout/stderr 重定向到 `~/.harbor/logs/{service-name}-{timestamp}.log`
- **AND** 进程独立于 Harbor 运行，Harbor 退出后进程继续

#### Scenario: 工作目录为空时后台启动
- **WHEN** 收藏服务的 `workingDirectory` 为空字符串
- **THEN** 使用用户主目录 `~` 作为 `currentDirectoryURL`

#### Scenario: 后台启动失败
- **WHEN** 后台启动进程失败（命令不存在、权限不足等）
- **THEN** 在主界面错误区域显示错误信息

### Requirement: 日志文件管理
系统 SHALL 将后台启动服务的日志保存到统一目录，文件名包含服务名和启动时间戳。

#### 日志路径规则
- 目录：`~/.harbor/logs/`
- 文件名：`{service-name}-{yyyy-MM-dd_HH-mm-ss}.log`
- 示例：`~/.harbor/logs/my-api-2026-05-19_14-30-00.log`

#### Scenario: 首次后台启动创建日志目录
- **WHEN** `~/.harbor/logs/` 目录不存在
- **THEN** 自动创建目录

#### Scenario: 同一服务多次启停
- **WHEN** 同一服务多次后台启动
- **THEN** 每次启动生成独立的日志文件（时间戳不同），不会覆盖历史日志

#### Scenario: 日志文件编码
- **WHEN** 写入日志文件
- **THEN** 使用 UTF-8 编码

### Requirement: 双启动按钮 UI
系统 SHALL 在 `idleFavoriteButtons` 区域显示两个启动按钮并排：

| 按钮 | 图标 | 颜色 | tooltip | 行为 |
|------|------|------|---------|------|
| 终端启动 | `play.circle` | accent | "Launch in Terminal" | 通过 Terminal.app 启动 |
| 后台启动 | `play.circle.fill` | accent | "Launch in background" | 通过 Process 后台启动 |

#### Scenario: idleFavoriteButtons 布局
- **WHEN** 收藏服务未运行
- **THEN** 操作区显示：终端启动按钮 + 后台启动按钮 + 编辑按钮，从左到右排列

#### Scenario: 后台启动按钮悬停
- **WHEN** 鼠标悬停在后台启动按钮上
- **THEN** 按钮颜色变为主题 accent 色，与终端启动按钮悬停行为一致

### Requirement: 后台启动进程的发现与匹配
后台启动的进程 SHALL 通过现有的 lsof 进程发现机制自动检测，无需额外的进程注册机制。

#### Scenario: 后台启动后自动发现
- **WHEN** 后台启动的服务开始监听端口
- **THEN** 下一次 lsof 轮询（3秒间隔）自动发现该进程
- **AND** 如果该服务是收藏服务，自动匹配为 `favoriteRunning` 状态

#### Scenario: Harbor 退出后进程继续运行
- **WHEN** Harbor 退出后重新启动
- **THEN** 之前后台启动的服务如果仍在运行，通过 lsof 重新发现

## MODIFIED Requirements

### Requirement: ServiceLaunchService
原：仅支持 `launch(workingDirectory:startCommand:)` 通过 Terminal.app 启动
现：新增 `launchInBackground(workingDirectory:startCommand:serviceName:) throws` 方法

### Requirement: idleFavoriteButtons
原：终端启动 + 编辑（2 个按钮）
现：终端启动 + 后台启动 + 编辑（3 个按钮）

### Requirement: ProcessMonitorViewModel
原：仅支持 `launchService(_:)` 通过 Terminal 启动
现：新增 `launchServiceInBackground(_:)` 方法

## REMOVED Requirements
无

## 技术说明：工作目录问题

**日志文件位置 ≠ 进程工作目录**，两者完全独立：
- `Process.currentDirectoryURL` = 服务的 `workingDirectory`（如 `/Users/lian/projects/my-app/`）
  - 确保 `npm run dev` 能找到 `package.json`、`cargo run` 能找到 `Cargo.toml`
- 日志文件路径 = `~/.harbor/logs/{name}-{timestamp}.log`
  - 仅是 stdout/stderr 的重定向目标，不影响进程的当前工作目录

这与 Terminal 启动方式等价：Terminal 窗口缓冲区 → 磁盘文件，进程仍在正确目录下运行。
