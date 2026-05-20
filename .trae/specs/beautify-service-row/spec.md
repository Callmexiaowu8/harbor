# 服务行 UI 美化与星号取消收藏 Spec

## Why
当前服务列表行的信息展示过于臃肿——一行同时显示「启动命令 · 工作目录 · 进程名 · PID · 端口」共 5 项信息，导致文字换行混乱（截图可见 Port 3000 被挤成竖排）、信息层级不清、整体视觉拥挤。同时，已收藏服务的星标图标不可交互，用户无法通过再次点击星号取消收藏，只能使用操作区的移除按钮，交互不够直观。

## What Changes
- **精简 `detailLine`**：从 5 项信息缩减为「端口 + PID」两项，启动命令和工作目录移至 tooltip
- **星号可点击取消收藏**：`favoriteRunning` 和 `favoriteIdle` 的填充星标改为可点击，触发取消收藏确认流程
- **移除操作区中的"移除收藏"按钮**：取消收藏统一由星号完成，减少操作区按钮数量
- **tooltip 补充信息**：整行 hover 时 tooltip 显示完整信息（启动命令、工作目录、进程名等）

## Impact
- Affected code: `ServiceListRowView.swift`, `MainView.swift`
- No new files needed

## ADDED Requirements

### Requirement: 精简服务行信息展示
系统 SHALL 精简每条服务行的详情行，仅保留核心运行状态信息：

#### 信息层级设计
| 层级 | 内容 | 展示方式 |
|------|------|---------|
| **主标题** | 服务名称 | 13pt semibold，始终显示 |
| **副标题（运行中）** | 端口徽章 + PID | 10.5pt monospaced，仅运行时显示 |
| **副标题（未运行）** | 启动命令 | 10.5pt monospaced，仅未运行的收藏服务显示 |
| **隐藏信息** | 工作目录、完整进程名、完整路径 | 通过 tooltip 或编辑界面查看 |

#### Scenario: 运行中的收藏服务（favoriteRunning）
- **WHEN** 收藏服务正在运行
- **THEN** 显示：第一行=服务名；第二行=端口徽章（高亮 accent 色）+ PID 文字

#### Scenario: 未运行的收藏服务（favoriteIdle）
- **WHEN** 收藏服务未运行
- **THEN** 显示：第一行=服务名；第二行=启动命令（textTertiary 色）

#### Scenario: 未收藏的运行中服务（runningOnly）
- **WHEN** 服务正在运行但未被收藏
- **THEN** 显示：第一行=服务名；第二行=端口徽章 + PID 文字

### Requirement: 星号取消收藏
系统 SHALL 支持通过点击已收藏服务的星标图标来取消收藏。

#### 交互规则
| 状态 | 图标 | 点击行为 |
|------|------|---------|
| `runningOnly` | `star` 轮廓 | 点击 → 添加到收藏 |
| `favoriteRunning` | `star.fill` 填充 | 点击 → 取消收藏确认 |
| `favoriteIdle` | `star.fill` 填充 | 点击 → 取消收藏确认 |

#### Scenario: 点击填充星标取消收藏
- **WHEN** 用户点击已收藏服务的填充星标（`star.fill`）
- **THEN** 展开确认栏，提示"Remove {name} from favorites?"，提供 Cancel/Remove 按钮
- **WHEN** 用户点击 Remove
- **THEN** 执行取消收藏，该服务从收藏列表移除
- **WHEN** 用户点击 Cancel
- **THEN** 收起确认栏，不做任何操作

#### Scenario: 取消收藏不终止进程
- **WHEN** 正在运行的收藏服务被取消收藏
- **THEN** 仅从收藏列表移除，进程继续运行不受影响，该项变为 `runningOnly` 行显示

### Requirement: 星号悬停反馈
已收藏服务的填充星标在悬停时应提供视觉反馈，暗示可点击。

#### Scenario: 填充星标悬停
- **WHEN** 鼠标悬停在已收藏服务的填充星标上
- **THEN** 图标颜色略微变淡或添加微妙的透明度变化，光标变为 pointer
- **AND** tooltip 显示 "Remove from favorites"

#### Scenario: 轮廓星标悬停（不变）
- **WHEN** 鼠标悬停在未收藏服务的轮廓星标上
- **THEN** 保持现有行为：颜色变为主题 accent 色
- **AND** tooltip 显示 "Add to favorites"

### Requirement: Tooltip 完整信息
系统 SHALL 在服务行上提供 tooltip 显示被隐藏的详细信息。

#### Scenario: 整行 hover 显示 tooltip
- **WHEN** 鼠标悬停在服务行上
- **THEN** tooltip 显示多行完整信息：
  - 收藏服务：`{name}\nCommand: {startCommand}\nDirectory: {workingDirectory}`
  - 运行中服务：`{name}\nProcess: {command}\nPID: {pid}\nPort: {port}`
  - 收藏+运行：合并两者信息

## MODIFIED Requirements

### Requirement: ServiceListRowView 操作区域
原：`favoriteRunning` = 打开 + 编辑 + 终止；`favoriteIdle` = 启动 + 编辑 + 移除
现：
- `favoriteRunning` = 打开 + 编辑 + 终止（移除"移除收藏"按钮，由星号替代）
- `favoriteIdle` = 启动 + 编辑（移除"移除收藏"按钮，由星号替代）

### Requirement: ServiceListRowView statusIcon
原：`favoriteRunning`/`favoriteIdle` 显示静态 `star.fill` 图片
现：`favoriteRunning`/`favoriteIdle` 显示可点击的 `star.fill` 按钮，点击触发取消收藏确认

### Requirement: 确认栏逻辑
原：确认栏区分终止进程和移除收藏两种场景
现：新增第三种场景——通过星号触发的取消收藏。确认消息和回调与原"移除收藏"一致，但触发源不同（星号 vs 移除按钮）

## REMOVED Requirements
无
