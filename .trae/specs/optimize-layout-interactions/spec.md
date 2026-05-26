# Popover 布局与交互优化 Spec

## Why
项目分组头部与服务行视觉不一致、分组不支持收藏、分组内服务卡片缩进效果不完整、服务卡片文字溢出无截断、子进程数量展示形式不佳，需要逐一优化。

## What Changes
- 项目分组头部改为与服务行相同的卡片样式（圆角矩形背景+阴影+相同 padding）
- 项目分组头部添加星标按钮，点击可收藏分组下所有服务
- 分组内服务卡片整体缩进（卡片宽度变窄，而非仅文字偏移）
- 服务卡片固定高度，文字溢出使用省略号截断
- 移除服务名称旁的 "N processes" 按钮，改为在 detailLine 中用小徽章显示子进程数量

## Impact
- Affected specs: refine-popover-details（分组头部样式修改、子进程展示修改）
- Affected code:
  - `ServiceListRowView.swift` — 分组头部卡片化、星标按钮、服务卡片缩进、固定高度+省略号、子进程徽章
  - `ProcessMonitorViewModel.swift` — 批量收藏分组方法
  - `MainView.swift` — 分组收藏回调

## ADDED Requirements

### Requirement: 项目分组头部卡片化
项目分组头部 SHALL 使用与服务行相同的卡片样式，包括圆角矩形背景、阴影和相同的 padding。

#### Scenario: 分组头部卡片样式
- **WHEN** 项目分组头部渲染
- **THEN** 使用 RoundedRectangle(cornerRadius: 10) 背景填充 theme.surfaceRaised
- **AND** 悬停时背景变为 theme.surfaceHover
- **AND** 添加与服务行相同的阴影效果
- **AND** padding 与服务行一致（.horizontal 14, .vertical 12）
- **AND** 整体视觉大小与服务行卡片一致

### Requirement: 项目分组支持收藏
项目分组头部 SHALL 显示星标按钮，点击可将分组下所有服务加入收藏。

#### Scenario: 分组头部星标按钮
- **WHEN** 项目分组头部渲染
- **THEN** 在文件夹图标位置显示星标图标（star 或 star.fill）
- **AND** 如果分组下所有服务都已收藏，显示 star.fill（accent 色）
- **AND** 如果分组下部分或全部服务未收藏，显示 star（textTertiary 色）

#### Scenario: 点击星标收藏分组
- **WHEN** 用户点击分组头部的星标按钮
- **THEN** 将分组下所有未收藏的服务添加到收藏
- **AND** 为每个新收藏的服务弹出编辑面板（使用现有的 addFavoriteFromProcess 流程）
- **AND** 星标图标变为 star.fill

#### Scenario: 点击已收藏分组的星标
- **WHEN** 用户点击已全部分收藏的分组头部星标
- **THEN** 展开确认栏，提示 "Remove all services in {name} from favorites?"
- **AND** 用户确认后移除分组下所有服务的收藏

### Requirement: 分组内服务卡片整体缩进
属于项目分组的服务卡片 SHALL 整体缩进，卡片宽度变窄，而非仅文字偏移。

#### Scenario: 分组内服务卡片缩进
- **WHEN** 服务行属于某个项目分组（groupKey 不为 nil）
- **THEN** 整个卡片（包括背景、描边、阴影）向右缩进约 20pt
- **AND** 卡片右侧保持与列表边缘对齐（不缩进）
- **AND** 卡片宽度比非分组服务窄约 20pt

#### Scenario: 非分组服务卡片不缩进
- **WHEN** 服务行不属于任何项目分组
- **THEN** 卡片保持原有宽度，无缩进

### Requirement: 服务卡片固定高度+文字省略号
服务卡片 SHALL 使用固定高度，文字内容过多时使用省略号截断。

#### Scenario: 服务名称过长
- **WHEN** 服务名称超过卡片可用宽度
- **THEN** 名称文字截断并显示省略号（...）
- **AND** 卡片高度不变

#### Scenario: 启动命令过长
- **WHEN** 未运行收藏服务的启动命令超过卡片可用宽度
- **THEN** 命令文字截断并显示省略号
- **AND** 卡片高度不变

#### Scenario: 正常长度内容
- **WHEN** 服务名称和详情信息在可用宽度内
- **THEN** 正常显示，不截断

### Requirement: 子进程数量用 detailLine 行内小徽章展示
子进程数量 SHALL 在 detailLine（Port|PID 同行）中用小徽章展示，替代当前服务名称旁的 "N processes" 按钮。

#### Scenario: 有子进程的运行中服务
- **WHEN** 服务正在运行且有子进程
- **THEN** detailLine 显示：Port 徽章 + PID + 子进程数量徽章（如 "×2"）
- **AND** 子进程数量徽章使用小号字体、accent 色文字 + accent.opacity(0.12) 背景
- **AND** 点击子进程数量徽章可展开/收起子进程列表

#### Scenario: 无子进程的运行中服务
- **WHEN** 服务正在运行且无子进程
- **THEN** detailLine 仅显示 Port 徽章 + PID，无子进程徽章

#### Scenario: 服务名称行不再显示 "N processes"
- **WHEN** 任何服务行渲染
- **THEN** 服务名称旁不显示 "N processes" 按钮或徽章
- **AND** 子进程信息统一在 detailLine 中展示

## MODIFIED Requirements

### Requirement: ProjectGroupHeaderView 样式
原：纯文字标签式，无背景卡片
现：卡片样式，圆角矩形背景 + 阴影 + 与服务行一致的 padding

### Requirement: ProjectGroupHeaderView 星标
原：无星标，仅显示文件夹图标
现：左侧显示星标图标（替代文件夹图标），支持收藏/取消收藏分组

### Requirement: ServiceRowContent 分组缩进
原：仅文字内容偏移（.padding(.leading, 34)），卡片背景仍占满宽度
现：整个卡片缩进（使用 margin/padding 在卡片外部），卡片宽度变窄

### Requirement: 子进程数量展示
原：服务名称旁显示 "N processes" 按钮（chevron + 文字 + 背景胶囊）
现：移除名称旁的按钮，在 detailLine 中用小徽章展示（如 "×2"），点击可展开

## REMOVED Requirements
无
