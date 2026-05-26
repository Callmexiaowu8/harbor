# 修复分组 key、取消收藏、停止服务展示 Spec

## Why
存在三个 bug：（1）分组字典的 key 存的是项目名而非项目目录路径，导致折叠状态管理不准确；（2）取消收藏（Remove）操作后星标未消失，收藏状态未正确更新；（3）已停止的收藏服务显示异常，startCommand 文本溢出卡片边界。

## What Changes
- 分组字典 key 从项目名改为项目所在目录路径
- 排查并修复取消收藏后视图不更新的问题
- 已停止服务的详情行添加文本截断和容器约束，防止溢出

## Impact
- Affected code: `ProcessMonitorViewModel.swift`（分组 key）、`ServiceListRowView.swift`（详情行溢出）、可能涉及 MainView 回调连接

## ADDED Requirements
无

## MODIFIED Requirements

### Requirement: 分组字典使用目录路径作为 key
系统 SHALL 使用项目的实际工作目录（或公共父目录）作为分组字典的 key，而非项目名称。这确保：
- 折叠/展开状态按目录维度管理，避免同名项目冲突
- `toggleGroupCollapse` 的参数语义清晰

#### Scenario: 分组 key 为目录路径
- **WHEN** 项目 blood-pressure-monitor 的 frontend 在 `/Users/x/project/blood-pressure-monitor/frontend`
- **THEN** 分组 key 为 `/Users/x/project/blood-pressure-monitor`（公共父目录），组显示名为 `blood-pressure-monitor`

### Requirement: 取除收藏后立即更新视图
用户点击确认栏的 "Remove" 按钮后，该服务行应立即从收藏列表中移除（或变为非收藏的运行中服务），星标图标应消失。

#### Scenario: 取消收藏
- **WHEN** 用户点击收藏服务的星标 → 确认栏出现 → 点击 "Remove"
- **THEN** 服务从 favoriteServices 中移除，视图立即更新，星标消失

### Requirement: 停止服务的命令文本不溢出
已停止的收藏服务在详情行显示 startCommand 时，长命令文本应被正确截断，不超出卡片边界。

#### Scenario: 长启动命令
- **WHEN** 收藏服务的 startCommand 为 `cd "/Users/lian/x-code101/iSpace/backend" && .venv/bin/uvicorn app.main:app --reload --port 8100`
- **THEN** 详情行显示截断后的文本（如 `cd "/Users/lian/x-code101/iSpace/backend" && .venv/bin/uvic...`），不溢出卡片

## REMOVED Requirements
无
