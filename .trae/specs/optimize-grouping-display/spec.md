# 优化项目分组展示 Spec

## Why
当前实现存在两个问题：（1）单服务的项目也显示了文件夹组头行，造成视觉噪音和冗余；（2）同一项目的多服务（如 frontend/backend 子目录）因 workingDirectory 不同而被错误地分到不同组中。需要优化分组逻辑和展示规则。

## What Changes
- 修改项目识别逻辑：从精确匹配 workingDirectory 改为自动检测公共父目录分组 + 支持手动覆盖
- 修改展示规则：仅当组内 ≥ 2 个服务时才显示项目组头，单个服务直接平铺
- FavoriteService 新增可选 `projectName` 字段用于手动覆盖项目归属

## Impact
- Affected code: `ProcessMonitorViewModel.swift`（分组逻辑）、`FavoriteService.swift`（新增字段）、`ServiceListRowView.swift`（展示条件）
- Affected specs: `group-by-project-and-hierarchy`

## ADDED Requirements

### Requirement: 自动检测公共父目录分组
系统 SHALL 自动识别属于同一大项目的多个服务，通过查找 workingDirectory 的公共父目录进行分组。

#### Scenario: 前后端子目录归为一组
- **WHEN** 进程 A 的 workingDirectory 为 `/Users/x/project/blood-pressure-monitor/frontend`，进程 B 为 `/Users/x/project/blood-pressure-monitor/backend`
- **THEN** 两者的公共父目录为 `blood-pressure-monitor`，归入同一组，组名为 "blood-pressure-monitor"

#### Scenario: 单级目录的服务
- **WHEN** 进程的 workingDirectory 为 `/Users/x/project/EmailApp`
- **THEN** 项目根目录为 `EmailApp`，与其他同级目录的服务独立分组

#### Scenario: 公共父目录检测算法
- **WHEN** 有 N 个 workingDirectory
- **THEN** 算法步骤：
  1. 过滤掉空路径，保留有效 workingDirectory
  2. 按路径组件逐级拆分，找到所有路径的最长公共前缀（LCP）
  3. 在 LCP 的下一级目录名进行分组
  4. 无法归组的路径各自独立成组（取最后一级目录名）

### Requirement: 单服务不显示组头
系统 SHALL 仅在项目组内包含 ≥ 2 个服务时才渲染项目组头行。

#### Scenario: 单服务项目
- **WHEN** 项目组内只有 1 个服务（如 EmailApp）
- **THEN** 不显示 projectHeader 行，直接显示 serviceRow

#### Scenario: 多服务项目
- **WHEN** 项目组内有 ≥ 2 个服务（如 blood-pressure-monitor 含 frontend + backend）
- **THEN** 显示 projectHeader 行（项目名 + 服务数量 + 折叠按钮）

### Requirement: 手动覆盖项目归属
系统 SHALL 允许用户在编辑收藏服务时手动指定项目名称，优先于自动检测结果。

#### Scenario: 手动指定项目名
- **WHEN** 用户编辑收藏服务时设置了自定义 projectName
- **THEN** 该服务归入指定的项目组，忽略自动检测的父目录

#### Scenario: 未指定时自动检测
- **WHEN** 用户未设置 projectName
- **THEN** 使用自动检测的公共父目录作为项目归属

## MODIFIED Requirements

### Requirement: FavoriteService 数据模型
FavoriteService 新增可选字段 `projectName: String?`，默认 nil 表示自动检测。

### Requirement: ProcessMonitorViewModel 分组逻辑
`serviceListItems` 计算属性重构：
1. 先处理手动指定了 projectName 的收藏服务，按 projectName 分组
2. 剩余服务按公共父目录算法自动分组
3. 合并两组结果
4. 仅对 count ≥ 2 的组生成 DisplayItem.projectHeader

## REMOVED Requirements
无
