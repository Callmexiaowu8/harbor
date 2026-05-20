# 收藏服务交互增强 Spec

## Why
当前收藏功能缺少两个关键交互：已收藏服务无法编辑配置（如修改启动命令），运行中服务无法直接收藏（需手动添加）。这两个缺失导致用户必须删除再重新添加才能修改配置，且无法从运行中服务快速创建收藏，操作路径过长。

## What Changes
- 修改 `ServiceListRowView`，为未收藏的运行中服务添加可点击的星号轮廓图标（`star`），为已收藏服务添加编辑按钮（`pencil.circle`）
- 重构 `AddServiceView`，支持"编辑模式"（预填充现有收藏配置，标题和按钮文案切换）
- 扩展 `ProcessMonitorViewModel`，添加 `updateFavorite(_:)` 方法和从运行中进程创建收藏的 `addFavoriteFromProcess(_:)` 方法
- 修改 `MainView`，支持编辑收藏的 sheet 弹出和从运行中服务收藏后自动弹出编辑

## Impact
- Affected code: `ServiceListRowView.swift`, `AddServiceView.swift`, `ProcessMonitorViewModel.swift`, `MainView.swift`
- No new files needed

## ADDED Requirements

### Requirement: 编辑已收藏服务
系统 SHALL 支持编辑已收藏服务的配置，包括名称、工作目录、启动命令和端口。

#### Scenario: 编辑收藏服务
- **WHEN** 用户点击收藏服务行的编辑按钮（`pencil.circle` 图标）
- **THEN** 弹出 AddServiceView 编辑模式 sheet，预填充该收藏服务的当前配置（名称、工作目录、启动命令、端口）
- **AND** 标题显示"Edit Service"，确认按钮显示"Save"

#### Scenario: 保存编辑
- **WHEN** 用户在编辑模式中修改字段后点击 Save
- **THEN** 系统更新该收藏服务的配置并持久化，列表即时反映变更
- **AND** 收藏服务的 `id` 和 `createdAt` 保持不变

#### Scenario: 取消编辑
- **WHEN** 用户在编辑模式中点击 Cancel 或关闭按钮
- **THEN** 不做任何修改，收起 sheet

### Requirement: 从运行中服务收藏
系统 SHALL 支持通过点击星号图标将运行中的服务添加到收藏。

#### Scenario: 点击星号收藏运行中服务
- **WHEN** 用户点击未收藏运行中服务的星号轮廓图标（`star`）
- **THEN** 系统立即创建收藏服务，自动填充：名称=进程名、工作目录=进程 CWD（如有）、端口=进程端口、启动命令=进程 command
- **AND** 自动弹出 AddServiceView 编辑模式 sheet，让用户确认或修改配置（特别是启动命令）
- **AND** 该服务行立即从 `runningOnly` 切换为 `favoriteRunning`，星标变为填充状态

#### Scenario: 运行中服务无 CWD 信息
- **WHEN** 用户收藏一个没有 CWD 信息的运行中服务
- **THEN** 工作目录字段留空，用户需在编辑表单中手动填写

#### Scenario: 已收藏服务不显示星号轮廓
- **WHEN** 服务已被收藏（`favoriteRunning` 或 `favoriteIdle`）
- **THEN** 状态图标区域显示填充星标（`star.fill`），不提供重复收藏操作

### Requirement: 星号图标交互设计
系统 SHALL 在 `ServiceListRowView` 中为不同状态的服务显示差异化星号图标：

| 服务状态 | 图标 | 交互 |
|---------|------|------|
| `runningOnly`（未收藏运行中） | `star`（轮廓） | 可点击，触发收藏+编辑流程 |
| `favoriteRunning`（收藏+运行中） | `star.fill`（填充） | 不可点击，仅标识 |
| `favoriteIdle`（收藏+未运行） | `star.fill`（填充） | 不可点击，仅标识 |

#### Scenario: 星号轮廓悬停反馈
- **WHEN** 用户将鼠标悬停在未收藏运行中服务的星号轮廓图标上
- **THEN** 图标颜色变为主题 accent 色，提供视觉反馈表明可点击

#### Scenario: 星号点击反馈
- **WHEN** 用户点击星号轮廓图标
- **THEN** 图标从轮廓（`star`）动画过渡为填充（`star.fill`），同时弹出编辑 sheet

### Requirement: 编辑按钮交互设计
系统 SHALL 在已收藏服务的操作区域添加编辑按钮：

| 服务状态 | 操作按钮 |
|---------|---------|
| `favoriteRunning` | 打开浏览器 + 编辑 + 终止 |
| `favoriteIdle` | 启动 + 编辑 + 移除 |
| `runningOnly` | 打开浏览器 + 终止（不变） |

#### Scenario: 编辑按钮悬停反馈
- **WHEN** 用户将鼠标悬停在编辑按钮上
- **THEN** 按钮颜色变为主题 accent 色，与其他操作按钮悬停行为一致

#### Scenario: 编辑按钮帮助提示
- **WHEN** 用户悬停在编辑按钮上
- **THEN** 显示 tooltip "Edit service"

### Requirement: AddServiceView 编辑模式
系统 SHALL 使 `AddServiceView` 同时支持添加和编辑两种模式：

- 编辑模式通过传入可选的 `FavoriteService` 实例触发
- 编辑模式下：标题="Edit Service"，确认按钮="Save"，所有字段预填充
- 添加模式下：标题="Add Service"，确认按钮="Add"，字段为空（与现有行为一致）
- 编辑模式保存时调用 `onEdit` 回调而非 `onAdd`
- 编辑模式下工作目录字段应为只读（已收藏服务不应更改工作目录，否则匹配逻辑会失效）

#### Scenario: 编辑模式预填充
- **WHEN** AddServiceView 以编辑模式打开
- **THEN** 名称、工作目录（只读）、启动命令、端口字段均预填充当前值
- **AND** 自动检测按钮可用，可重新扫描目录获取最新命令列表

#### Scenario: 编辑模式保存
- **WHEN** 用户在编辑模式修改字段后点击 Save
- **THEN** 调用 `onEdit` 回调，传入更新后的 FavoriteService（保持原 id 和 createdAt）
- **AND** ViewModel 更新收藏列表中对应项并持久化

## MODIFIED Requirements

### Requirement: ServiceListRowView 状态图标
原：`runningOnly` 显示 `StatusIndicatorView`，收藏项显示 `star.fill`
现：`runningOnly` 显示可点击的 `star` 轮廓图标（替代 `StatusIndicatorView`），悬停变色，点击触发收藏；收藏项显示 `star.fill`（不变）

### Requirement: ServiceListRowView 操作区域
原：`favoriteRunning` 显示打开+终止，`favoriteIdle` 显示启动+移除
现：`favoriteRunning` 显示打开+编辑+终止，`favoriteIdle` 显示启动+编辑+移除

### Requirement: MainView sheet 管理
原：仅管理 `showAddService` 状态
现：同时管理 `editingFavorite: FavoriteService?` 状态，支持编辑模式 sheet 弹出

### Requirement: ProcessMonitorViewModel 收藏管理
原：仅支持 `addFavorite` 和 `removeFavorite`
现：新增 `updateFavorite(_:)` 更新收藏配置，新增 `addFavoriteFromProcess(_:)` 从运行中进程创建收藏

## REMOVED Requirements
无
