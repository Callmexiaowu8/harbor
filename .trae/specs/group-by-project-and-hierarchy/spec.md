# 项目分组与父子进程展示 Spec

## Why
当一个项目同时包含前端和后端服务时，当前各自独立显示，缺乏项目维度的组织；当一个进程包含子进程时（如 uvicorn --reload 的 reloader + server），同一端口出现多行重复显示，信息冗余且终止操作不直观。

## What Changes
- 按项目工作目录对服务进行分组，组头显示项目名，可折叠/展开
- 同一端口的父子进程合并展示：主进程独占一行，子进程附在下方（可折叠/展开，缩进显示）
- 修改 `ProcessDiscoveryService` 检测进程的父进程 PID（ppid）
- 修改 `ProcessMonitorViewModel` 构建分组+层级的数据结构
- 修改 `ServiceListRowView` 支持项目组头、子进程缩进行、折叠/展开交互

## Impact
- Affected code: `ProcessDiscoveryService.swift`、`ProcessMonitorViewModel.swift`、`ServiceListRowView.swift`、`MainView.swift`、`ServerProcess.swift`
- Affected specs: `distinguish-service-states`、`beautify-service-row`

## ADDED Requirements

### Requirement: 按项目目录分组展示
系统 SHALL 将同一工作目录下的服务归为一组，组头显示项目名称，组内服务可折叠/展开。

#### Scenario: 同一项目有前端和后端服务
- **WHEN** 项目 `/Users/x/project` 下有前端服务（port 3001）和后端服务（port 8100）
- **THEN** 显示一个项目组，组头为项目名（如从 package.json/pyproject.toml 解析），组内包含两个服务行

#### Scenario: 不同项目的服务
- **WHEN** 有两个不同目录下的服务
- **THEN** 分别显示为两个独立的项目组

#### Scenario: 无工作目录的进程
- **WHEN** 进程无法获取工作目录
- **THEN** 归入"Other"默认组

#### Scenario: 收藏服务与项目组的交互
- **WHEN** 收藏服务属于某个项目组
- **THEN** 收藏服务在项目组内显示，保持收藏标识和操作

### Requirement: 父子进程层级展示
系统 SHALL 将同一端口的父子进程合并展示，主进程独占一行，子进程附在下方（缩进，可折叠/展开）。

#### Scenario: uvicorn --reload 场景
- **WHEN** uvicorn reloader 进程（PID 22546）监听端口 8100，其子进程 server（PID 22550）也监听端口 8100
- **THEN** 主进程（reloader）独占一行，子进程（server）显示在下方，缩进展示，可折叠/展开

#### Scenario: 终止主进程
- **WHEN** 用户终止主进程
- **THEN** 主进程及其所有子进程一起被终止

#### Scenario: 无子进程的普通服务
- **WHEN** 服务只有单个进程
- **THEN** 正常显示一行，无折叠/展开控件

### Requirement: 进程父进程检测
系统 SHALL 在进程发现时获取每个进程的父进程 PID（ppid），用于识别父子关系。

#### Scenario: 获取 ppid
- **WHEN** 发现一个监听进程
- **THEN** 通过 `ps -o ppid= -p <pid>` 获取其父进程 PID，存入 ServerProcess.ppid

## MODIFIED Requirements

### Requirement: ServerProcess 数据模型
ServerProcess 新增 `ppid` 字段，用于标识父进程 PID。

### Requirement: ServiceListItem 数据结构
ServiceListItem 需要支持三种展示类型：
- 项目组头（项目名 + 折叠/展开按钮）
- 主服务行（可能含子进程列表）
- 子进程行（缩进展示）

## REMOVED Requirements
无
