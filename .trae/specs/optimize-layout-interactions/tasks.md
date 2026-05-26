# Tasks

- [x] Task 1: ServiceListRowView.swift 项目分组头部卡片化
  - [x] 1.1: 为 ProjectGroupHeaderView 添加 RoundedRectangle 背景填充（theme.surfaceRaised / theme.surfaceHover）
  - [x] 1.2: 添加描边 overlay（theme.border.opacity(0.4/0.8)）
  - [x] 1.3: 添加阴影效果（与服务行一致）
  - [x] 1.4: 调整 padding 与服务行一致（.horizontal 14, .vertical 12）
  - [x] 1.5: 添加 hover 效果（背景色变化）

- [x] Task 2: ServiceListRowView.swift 项目分组星标按钮
  - [x] 2.1: 将文件夹图标替换为星标图标（star/star.fill），根据分组下服务收藏状态切换
  - [x] 2.2: 添加 onFavoriteGroup 回调到 ProjectGroupHeaderView 和 ServiceListRowView
  - [x] 2.3: 点击星标收藏分组下所有未收藏服务
  - [x] 2.4: 点击已收藏分组星标触发取消收藏流程
  - [x] 2.5: ProjectGroupHeaderView 接收 isAllFavorited 信息

- [x] Task 3: ProcessMonitorViewModel.swift 添加批量收藏方法
  - [x] 3.1: 添加 favoriteGroupServices 方法
  - [x] 3.2: 添加 unfavoriteGroupServices 方法
  - [x] 3.3: ProjectGroup 包含 isAllFavorited 字段

- [x] Task 4: MainView.swift 分组收藏回调
  - [x] 4.1: 添加 onFavoriteGroup 回调，调用 viewModel 的批量收藏方法
  - [x] 4.2: 收藏时弹出编辑面板

- [x] Task 5: ServiceListRowView.swift 分组内服务卡片整体缩进
  - [x] 5.1: 将分组内服务行的缩进从内容偏移改为卡片外部 margin
  - [x] 5.2: 使用 .padding(.leading, 20) 在卡片外部添加缩进
  - [x] 5.3: 卡片右侧保持与列表边缘对齐

- [x] Task 6: ServiceListRowView.swift 服务卡片固定高度+省略号
  - [x] 6.1: 为服务名称 Text 添加 .lineLimit(1) 和 .truncationMode(.tail)
  - [x] 6.2: 为启动命令 Text 添加 .lineLimit(1) 和 .truncationMode(.tail)

- [x] Task 7: ServiceListRowView.swift 子进程数量改为 detailLine 行内徽章
  - [x] 7.1: 移除服务名称旁的 "N processes" 按钮
  - [x] 7.2: 在 detailLine 中添加子进程数量徽章（"×N" 格式）
  - [x] 7.3: 子进程徽章可点击，触发 onToggleChildren
  - [x] 7.4: 移除 isChevronHovered 状态

# Task Dependencies
- Task 1 无依赖 ✅
- Task 2 依赖 Task 3 ✅
- Task 3 无依赖 ✅
- Task 4 依赖 Task 2 和 Task 3 ✅
- Task 5 无依赖 ✅
- Task 6 无依赖 ✅
- Task 7 无依赖 ✅
