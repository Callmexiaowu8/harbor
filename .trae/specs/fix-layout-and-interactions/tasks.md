# Tasks

- [x] Task 1: ServiceListRowView.swift 分组卡片与服务卡片大小完全对齐
  - [x] 1.1: 统一 ProjectGroupHeaderView 和 ServiceRowContent 的 HStack spacing 为 14
  - [x] 1.2: 确认两者 padding、圆角、阴影、描边参数完全一致
  - [x] 1.3: 统一图标尺寸（分组星标 width/height 20 与 服务 statusIcon 一致）

- [x] Task 2: ServiceListRowView.swift 子进程数量移至操作按钮行
  - [x] 2.1: 从 detailLine 中移除 "×N" 子进程徽章代码块
  - [x] 2.2: 在 runningActionButtons 中添加子进程数量按钮（chevron + 数字），位于 open 按钮之前
  - [x] 2.3: 点击子进程数量按钮触发 onToggleChildren

- [x] Task 3: ServiceListRowView.swift 子进程行卡片化+缩进
  - [x] 3.1: 将 ChildProcessRowView 的背景从半透明改为卡片样式（surfaceRaised/surfaceHover + 描边 + 阴影）
  - [x] 3.2: 将 padding(.vertical, 8) 改为 padding(.vertical, 12)
  - [x] 3.3: 将圆角半径从 8 改为 10
  - [x] 3.4: 将左侧缩进从 44pt 改为 20pt（使用外部 padding）
  - [x] 3.5: 移除 .padding(.leading, 44)，改为 .padding(.leading, 20) 在卡片外部

- [x] Task 4: ServiceListRowView.swift 分组收藏确认流程
  - [x] 4.1: 为 ProjectGroupHeaderView 添加 showConfirm 状态
  - [x] 4.2: 点击已收藏分组的星标时显示确认栏，确认后调用 onFavoriteGroup
  - [x] 4.3: 确认栏样式与服务行的确认栏一致

- [x] Task 5: 确保展开/收起分组动画一致
  - [x] 5.1: 已确认所有分组相关动画均使用 .spring(response: 0.35, dampingFraction: 0.8)

# Task Dependencies
- Task 1 无依赖 ✅
- Task 2 无依赖 ✅
- Task 3 无依赖 ✅
- Task 4 无依赖 ✅
- Task 5 无依赖 ✅
