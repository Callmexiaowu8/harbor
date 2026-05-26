# Tasks

- [x] Task 1: 更新 Theme.swift accent 色值为更淡更亮的天蓝色
  - [x] 1.1: 修改 HarborColors.dark 的 accent 为 `Color(red: 0.53, green: 0.87, blue: 1.0)` (#87DEFF)
  - [x] 1.2: 修改 HarborColors.dark 的 accentDim 为 `Color(red: 0.4, green: 0.82, blue: 0.99)` (#66D1FC)
  - [x] 1.3: 修改 HarborColors.light 的 accent 为 `Color(red: 0.13, green: 0.59, blue: 0.95)` (#2196F3)
  - [x] 1.4: 修改 HarborColors.light 的 accentDim 为 `Color(red: 0.1, green: 0.46, blue: 0.82)` (#1976D2)

- [x] Task 2: MainView.swift Filter 失焦自动关闭
  - [x] 2.1: 添加 @FocusState 追踪搜索框焦点状态
  - [x] 2.2: onChange 失焦时清空 searchText 并设置 showSearch = false

- [x] Task 3: MainView.swift 分组展开/收起改用 spring 动画
  - [x] 3.1: 将 withAnimation 改为 .spring(response: 0.35, dampingFraction: 0.8)

- [x] Task 4: ServiceListRowView.swift 移除运行指示条
  - [x] 4.1: 移除 .overlay(alignment: .leading) 运行指示竖条

- [x] Task 5: ServiceListRowView.swift "N processes" 徽章与名称同行
  - [x] 5.1: 确认徽章已在服务名称同行（无需额外修改）

- [x] Task 6: ServiceListRowView.swift 项目分组头部对齐服务行布局 + 编辑按钮
  - [x] 6.1: 调整 ProjectGroupHeaderView 字体大小和间距与服务行对齐
  - [x] 6.2: 添加编辑按钮（pencil.circle），hover 时显示
  - [x] 6.3: 添加 onEditGroup 回调到 ServiceListRowView

- [x] Task 7: ServiceListRowView.swift 分组内服务行缩进
  - [x] 7.1: 基于 groupKey 条件增加左侧缩进（34pt vs 14pt）

- [x] Task 8: ServiceListRowView.swift 子进程行增加缩进并移除连接线
  - [x] 8.1: 移除 ChildProcessRowView 中的 Rectangle 连接线
  - [x] 8.2: 增加左侧缩进至 44pt

- [x] Task 9: ProcessMonitorViewModel.swift 添加分组编辑方法
  - [x] 9.1: 添加 renameGroup 方法
  - [x] 9.2: 添加 updateGroupDirectory 方法
  - [x] 9.3: 添加 groupKey 字段到 ServiceRowItem

- [x] Task 10: MainView.swift 分组编辑面板
  - [x] 10.1: 添加 editingGroup 状态变量
  - [x] 10.2: 添加 .sheet(item:) 弹出 GroupEditSheet
  - [x] 10.3: 编辑面板包含项目名称和目录输入字段，保存/取消按钮
  - [x] 10.4: 保存时调用 viewModel 的分组编辑方法

# Task Dependencies
- Task 1 无依赖，可先行 ✅
- Task 2 无依赖，可先行 ✅
- Task 3 无依赖，可先行 ✅
- Task 4 无依赖，可先行 ✅
- Task 5 无依赖，可先行 ✅
- Task 6 依赖 Task 9 ✅
- Task 7 依赖 Task 9 (groupKey) ✅
- Task 8 无依赖，可先行 ✅
- Task 9 无依赖，可先行 ✅
- Task 10 依赖 Task 6 和 Task 9 ✅
