# 修复 detailLine 换行问题 Spec

## Why
detailLine 中的 Port | PID | 子进程徽章在空间不足时会换行，导致服务卡片高度与分组卡片不一致。之前的 `.layoutPriority(1)` 和各文本的 `.lineLimit(1)` 不足以阻止 HStack 换行。

## What Changes
- 为 detailLine HStack 添加 `.fixedSize(horizontal: true, vertical: false)` 强制单行显示
- 当内容超出可用宽度时，由 VStack 的 `.truncationMode` 或 `.lineLimit` 处理截断

## Impact
- Affected code: `ServiceListRowView.swift`

## ADDED Requirements

### Requirement: detailLine 强制单行不换行
detailLine HStack SHALL 始终在单行内显示所有元素，不换行。

#### Scenario: detailLine 不换行
- **WHEN** 服务卡片 detailLine 渲染（Port | PID | 子进程徽章）
- **THEN** 所有元素在同一行水平排列，不换行
- **AND** 即使空间不足，也不换行，而是被截断或压缩

#### Scenario: 服务卡片与分组卡片高度一致
- **WHEN** 分组卡片和服务卡片并排显示
- **THEN** 两者高度完全相同（均为两行文字 + padding）

## MODIFIED Requirements
无

## REMOVED Requirements
无
