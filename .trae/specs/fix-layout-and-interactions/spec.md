# Popover 交互与布局修复 Spec

## Why
分组收藏功能不完善、分组与服务卡片大小不一致、展开/收起动画不对称、子进程展示方式不佳、子进程缩进样式不统一，需要修复和优化。

## What Changes
- 修复分组收藏/取消收藏功能
- 分组卡片与服务卡片大小完全一致（padding、高度、图标尺寸等）
- 展开分组动画与收起动画保持一致（统一使用 spring）
- 移除 detailLine 中的 "×N" 子进程徽章，将子进程数量放在操作按钮行
- 子进程行使用缩进+卡片样式（圆角矩形背景+阴影），与服务行视觉一致

## Impact
- Affected specs: optimize-layout-interactions（子进程展示方式修改、卡片大小一致性）
- Affected code:
  - `ServiceListRowView.swift` — 分组卡片大小对齐、子进程徽章移至操作按钮行、子进程行卡片化+缩进
  - `ProcessMonitorViewModel.swift` — 分组收藏逻辑修复

## ADDED Requirements

### Requirement: 分组收藏/取消收藏功能完善
分组头部的星标按钮 SHALL 正确支持收藏和取消收藏操作。

#### Scenario: 收藏分组下所有服务
- **WHEN** 用户点击未全部分收藏的分组的星标按钮
- **THEN** 将分组下所有未收藏的服务添加到收藏
- **AND** 为第一个新收藏的服务弹出编辑面板
- **AND** 星标图标变为 star.fill

#### Scenario: 取消收藏分组下所有服务
- **WHEN** 用户点击已全部分收藏的分组的星标按钮
- **THEN** 展开确认栏，提示 "Remove all services in {name} from favorites?"
- **AND** 用户确认后移除分组下所有服务的收藏
- **AND** 星标图标变为 star

### Requirement: 分组与服务卡片大小完全一致
分组卡片和服务卡片 SHALL 在所有维度上保持一致，不允许有例外。

#### Scenario: 卡片尺寸一致性
- **WHEN** 分组卡片和服务卡片并排显示
- **THEN** 两者具有完全相同的：
  - 内边距（.horizontal 14, .vertical 12）
  - 圆角半径（10）
  - 阴影参数
  - 描边参数
  - 图标尺寸（statusIcon 区域 width 20, height 20）
  - 文字字体大小（名称 13pt semibold）
  - HStack spacing（14）

### Requirement: 展开分组动画与收起动画一致
展开分组的动画 SHALL 与收起分组的动画使用相同的 spring 参数。

#### Scenario: 展开/收起动画一致性
- **WHEN** 用户点击分组头部展开分组
- **THEN** 使用 `.spring(response: 0.35, dampingFraction: 0.8)` 动画
- **WHEN** 用户点击分组头部收起分组
- **THEN** 使用相同的 `.spring(response: 0.35, dampingFraction: 0.8)` 动画
- **AND** 两个方向的动画感觉完全对称

### Requirement: 子进程数量放在操作按钮行
子进程数量 SHALL 从 detailLine 移至操作按钮行，与 open/edit/terminate 按钮在同一行。

#### Scenario: 有子进程的运行中服务
- **WHEN** 服务正在运行且有子进程
- **THEN** 操作按钮行显示：子进程数量按钮 + open + edit + terminate
- **AND** 子进程数量按钮使用 chevron.right/chevron.down 图标 + 数字文字
- **AND** 点击子进程数量按钮可展开/收起子进程列表
- **AND** detailLine 仅显示 Port 徽章 + PID，不再显示子进程徽章

#### Scenario: 无子进程的运行中服务
- **WHEN** 服务正在运行且无子进程
- **THEN** 操作按钮行显示：open + edit + terminate（与当前一致）

### Requirement: 子进程行缩进+卡片样式
子进程行 SHALL 使用缩进+卡片样式（圆角矩形背景+阴影），与服务行视觉一致。

#### Scenario: 子进程行卡片样式
- **WHEN** 子进程行渲染
- **THEN** 使用 RoundedRectangle(cornerRadius: 10) 背景填充 theme.surfaceRaised
- **AND** 悬停时背景变为 theme.surfaceHover
- **AND** 添加与服务行相同的阴影效果
- **AND** 添加描边 overlay
- **AND** 左侧缩进约 20pt（与分组内服务行缩进一致）
- **AND** padding 与服务行一致（.horizontal 14, .vertical 12）

## MODIFIED Requirements

### Requirement: 子进程数量展示位置
原：在 detailLine 中用 "×N" 徽章展示
现：在操作按钮行中展示，与 open/edit/terminate 按钮同行

### Requirement: ChildProcessRowView 样式
原：半透明背景（surface.opacity(0.4)），无阴影，无描边，padding(.vertical, 8)
现：卡片样式（surfaceRaised/surfaceHover 背景，阴影，描边），padding(.vertical, 12)，缩进 20pt

## REMOVED Requirements
无
