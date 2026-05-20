# 区分运行中与收藏未运行服务 Spec

## Why
当前列表中运行中的本地服务和收藏但未运行的服务视觉区分不够明显——仅靠一个小灰色圆点 vs 星标图标和文字颜色微弱差异，用户快速扫描时难以区分服务状态。需要更直观、简洁的视觉区分。

## What Changes
- **运行中服务**：添加左侧 accent 色竖条指示器（2px 宽），表示"活跃"
- **收藏未运行服务**：整体降低透明度至 ~0.6，表示"未激活"
- **状态图标优化**：未运行收藏的灰色圆点改为空心圆，更清晰表达"停止"状态

## Impact
- Affected specs: None
- Affected code: `Sources/harbor/Views/ServiceListRowView.swift`

## ADDED Requirements
### Requirement: 运行状态视觉指示
系统 SHALL 为运行中的服务行添加明显的视觉标识，使用户一眼即可识别活跃服务。

#### Scenario: 运行中服务行样式
- **WHEN** 服务处于运行状态（isRunning = true）
- **THEN** 行左侧 SHALL 显示一条 2px 宽的 accent 色竖条
- **AND** 行整体 SHALL 保持完全不透明（opacity = 1.0）
- **AND** 文字颜色保持 textPrimary

#### Scenario: 收藏未运行服务行样式
- **WHEN** 服务是收藏但未运行（isFavorite = true, isRunning = false）
- **THEN** 行左侧 SHALL 不显示 accent 竖条
- **AND** 行整体 SHALL 降低透明度至约 0.6
- **AND** 状态图标 SHALL 使用空心圆（Circle().strokeBorder）代替实心灰色圆

### Requirement: 状态图标语义清晰
状态图标 SHALL 清晰传达服务的运行/停止状态。

#### Scenario: 未运行收藏的状态图标
- **WHEN** 服务是收藏但未运行
- **THEN** 状态图标 SHALL 显示空心圆轮廓（strokeBorder），颜色为 textTertiary
- **AND** 圆的尺寸 SHALL 与当前实心圆一致（8pt）

## MODIFIED Requirements
None

## REMOVED Requirements
None
