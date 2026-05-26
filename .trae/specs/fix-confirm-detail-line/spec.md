# Popover 细节修复 Spec

## Why
确认栏缺少 Cancel 按钮、分组与服务卡片高度因 detailLine 换行而不一致、子进程徽章格式需调整。

## What Changes
- 确认栏恢复 Cancel 按钮（同时保留点击任意位置取消功能）
- detailLine 强制单行不换行，确保服务卡片高度与分组一致
- 子进程徽章去掉 "×" 前缀，仅显示数字

## Impact
- Affected code: `ServiceListRowView.swift`

## ADDED Requirements

### Requirement: 确认栏恢复 Cancel 按钮
确认栏 SHALL 同时保留 Cancel 按钮和点击任意位置取消功能。

#### Scenario: 确认栏显示 Cancel 按钮
- **WHEN** 确认栏渲染
- **THEN** 显示提示文字 + Cancel 按钮 + 确认按钮（Terminate/Remove）
- **AND** 点击 Cancel 按钮取消确认
- **AND** 点击卡片其他位置（除确认按钮外）也取消确认

### Requirement: detailLine 强制单行不换行
detailLine 中的所有元素 SHALL 在同一行显示，不换行。

#### Scenario: detailLine 不换行
- **WHEN** 服务卡片 detailLine 渲染（Port | PID | 子进程徽章）
- **THEN** 所有元素在同一行水平排列
- **AND** 如果空间不足，各元素通过 truncationMode 截断而非换行
- **AND** 服务卡片高度与分组卡片一致

### Requirement: 子进程徽章去掉 "×" 前缀
子进程数量徽章 SHALL 仅显示数字，不显示 "×" 前缀。

#### Scenario: 子进程徽章格式
- **WHEN** 有子进程的运行中服务 detailLine 渲染
- **THEN** 子进程徽章显示 chevron + 数字（如 "2"），不显示 "×"

## MODIFIED Requirements

### Requirement: 确认栏交互
原：点击任意位置取消，无 Cancel 按钮
现：点击任意位置取消 + Cancel 按钮，两种方式并存

### Requirement: 子进程徽章格式
原：显示 "×N"
现：仅显示 "N"

## REMOVED Requirements
无
