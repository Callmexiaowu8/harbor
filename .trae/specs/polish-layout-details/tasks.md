# Tasks

- [x] Task 1: ServiceListRowView.swift 分组卡片高度与服务卡片一致
  - [x] 1.1: 将 ProjectGroupHeaderView 改为两行结构：VStack(name, directory)
  - [x] 1.2: 第二行显示 abbreviatedPath(group.directory)，10.5pt medium monospaced textTertiary
  - [x] 1.3: 移除 "N services" 文字

- [x] Task 2: ServiceListRowView.swift 子进程缩进叠加分组缩进
  - [x] 2.1: ChildProcessItem 添加 groupKey 字段
  - [x] 2.2: 更新 ProcessMonitorViewModel 传递 groupKey
  - [x] 2.3: ChildProcessRowView 缩进动态设置（40pt/20pt）

- [x] Task 3: ServiceListRowView.swift 确认栏交互优化
  - [x] 3.1: 移除 ServiceRowContent confirmBar 的 Cancel 按钮
  - [x] 3.2: 移除 ProjectGroupHeaderView 确认栏的 Cancel 按钮
  - [x] 3.3: ServiceRowContent 点击卡片背景取消确认
  - [x] 3.4: ProjectGroupHeaderView 点击卡片背景取消确认

- [x] Task 4: ServiceListRowView.swift 子进程数量移回 detailLine
  - [x] 4.1: 从 runningActionButtons 移除子进程数量按钮
  - [x] 4.2: 在 detailLine 中添加 ×N 徽章（Port | PID | ×N）

# Task Dependencies
- Task 1 无依赖 ✅
- Task 2 依赖 ViewModel 修改 ✅
- Task 3 无依赖 ✅
- Task 4 无依赖 ✅
