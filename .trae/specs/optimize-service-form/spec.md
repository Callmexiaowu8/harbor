# 优化收藏服务表单 Spec

## Why
当前收藏服务页面的 Port 字段是冗余的，因为端口信息已经包含在启动命令内。同时需要确保用户可以在编辑模式下完整修改服务的三个核心配置项（目录、启动命令、名称），提升用户体验和数据管理灵活性。

## What Changes
- **移除 Port 字段** - 删除 Port (optional) 输入框及相关状态变量和处理逻辑
- **优化 Name 字段布局** - 从 HStack 双列布局改为全宽单列布局
- **增强编辑功能** - 确保编辑模式下支持修改 Working Directory、Start Command、Name
- **简化数据模型交互** - saveService 方法不再处理 port 参数

## Impact
- Affected specs: None (isolated UI optimization)
- Affected code:
  - `Sources/harbor/Views/AddServiceView.swift` (主要修改)
  - `Sources/harbor/Models/FavoriteService.swift` (可选：考虑是否保留 port 字段以向后兼容)

## ADDED Requirements
### Requirement: 简化的服务配置表单
系统 SHALL 提供一个仅包含三个核心字段的服务配置界面。

#### Scenario: 添加新服务
- **WHEN** 用户打开"Add Service"对话框
- **THEN** 表单 SHALL 仅显示以下三个字段：
  1. **Working Directory** - 工作目录选择/显示
  2. **Start Command** - 启动命令输入
  3. **Name** - 服务名称输入
- **AND** 不再显示 Port 字段

#### Scenario: 编辑现有服务
- **WHEN** 用户打开"Edit Service"对话框
- **THEN** 所有三个字段 SHALL 可编辑：
  - Working Directory 支持重新选择或保持当前值
  - Start Command 支持修改
  - Name 支持修改
- **AND** 表单预填充当前服务的配置值

## MODIFIED Requirements
### Requirement: 表单布局优化
Name 字段 SHALL 使用全宽布局而非与 Port 字段并排显示。

#### Scenario: 响应式表单布局
- **WHEN** 表单渲染时
- **THEN** Name 字段 SHALL 占据整行宽度（而非原来的 50% 宽度）
- **AND** 字段间距和对齐方式与其他字段保持一致

### Requirement: 数据保存逻辑
保存服务时 SHALL 忽略 port 信息，仅保存核心三字段数据。

#### Scenario: 保存服务配置
- **WHEN** 用户点击"Add"或"Save"按钮
- **THEN** 系统 SHALL 创建/更新 FavoriteService 对象，包含：
  - name（必填）
  - workingDirectory（必填）
  - startCommand（必填）
  - port 设置为 nil 或保留默认值

## REMOVED Requirements
### Requirement: Port 配置字段
**原因**: Port 信息冗余，已包含在 startCommand 中（如 `--port 3000`）
**迁移**: 
- 已有服务的 port 数据保留在模型中以向后兼容，但 UI 不再暴露此字段
- 新添加的服务将 port 设为 nil
