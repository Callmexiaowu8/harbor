# Popover 布局与交互细节修复 Spec

## Why
分组与服务卡片高度不一致、子进程缩进未考虑分组层级、确认取消交互不够自然、子进程数量展示位置需要调整回 detailLine。

## What Changes
- 分组卡片高度与服务卡片完全一致（通过统一内容结构实现）
- 子进程行缩进叠加分组缩进（分组内服务的子进程缩进 40pt）
- 确认栏取消交互：点击除确认按钮外的任何地方都视为取消
- 子进程数量从操作按钮行移回 detailLine，与 Port | PID 同行

## Impact
- Affected specs: fix-layout-and-interactions（子进程展示位置修改、确认交互修改）
- Affected code:
  - `ServiceListRowView.swift` — 分组高度对齐、子进程缩进叠加、确认栏交互、子进程数量移回 detailLine

## ADDED Requirements

### Requirement: 分组与服务卡片高度完全一致
分组卡片和服务卡片 SHALL 具有完全相同的高度，不允许有例外。

#### Scenario: 卡片高度一致性
- **WHEN** 分组卡片和服务卡片并排显示
- **THEN** 两者高度完全相同
- **AND** 分组卡片需要包含第二行内容（如目录路径），使内容结构与服务的名称+detailLine 两行结构对应
- **AND** 分组卡片第二行显示目录路径（abbreviatedPath），字体样式与 detailLine 一致

### Requirement: 子进程缩进叠加分组缩进
子进程行的缩进 SHALL 叠加其父服务所属分组的缩进。

#### Scenario: 分组内服务的子进程缩进
- **WHEN** 子进程的父服务属于某个项目分组（groupKey 不为 nil）
- **THEN** 子进程行左侧缩进为 40pt（分组缩进 20pt + 子进程缩进 20pt）

#### Scenario: 非分组服务的子进程缩进
- **WHEN** 子进程的父服务不属于任何项目分组
- **THEN** 子进程行左侧缩进为 20pt（仅子进程缩进）

### Requirement: 确认栏点击任意位置取消
确认栏 SHALL 支持点击除确认按钮外的任何位置取消操作，无需专门的 Cancel 按钮。

#### Scenario: 点击确认栏外部取消
- **WHEN** 确认栏显示中，用户点击卡片内确认栏以外的区域
- **THEN** 确认栏关闭，操作取消

#### Scenario: 点击确认按钮执行操作
- **WHEN** 确认栏显示中，用户点击确认按钮（Terminate/Remove）
- **THEN** 执行对应操作，确认栏关闭

#### Scenario: 移除 Cancel 按钮
- **WHEN** 确认栏渲染
- **THEN** 不显示 Cancel 按钮
- **AND** 仅显示提示文字和确认按钮

### Requirement: 子进程数量在 detailLine 中展示
子进程数量 SHALL 在 detailLine 中与 Port | PID 同行展示，而非在操作按钮行。

#### Scenario: 有子进程的运行中服务
- **WHEN** 服务正在运行且有子进程
- **THEN** detailLine 显示：Port 徽章 | PID | ×N 徽章
- **AND** ×N 徽章可点击，触发展开/收起子进程列表
- **AND** 操作按钮行不显示子进程数量按钮

#### Scenario: 无子进程的运行中服务
- **WHEN** 服务正在运行且无子进程
- **THEN** detailLine 仅显示 Port 徽章 | PID

## MODIFIED Requirements

### Requirement: 子进程数量展示位置
原：在操作按钮行中展示（chevron + 数字按钮）
现：在 detailLine 中展示（×N 徽章，与 Port | PID 同行）

### Requirement: 确认栏交互
原：需要点击 Cancel 按钮取消
现：点击除确认按钮外的任何位置取消，移除 Cancel 按钮

### Requirement: ProjectGroupHeaderView 内容结构
原：单行 HStack（star + name + count + spacer + edit + chevron）
现：HStack(star + VStack(name + count, directory)) + spacer + edit + chevron，两行结构

### Requirement: ChildProcessRowView 缩进
原：固定 20pt 缩进
现：根据父服务是否在分组中动态缩进（20pt 或 40pt）

## REMOVED Requirements
无
