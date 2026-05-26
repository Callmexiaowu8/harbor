# Tasks

- [x] Task 1: 更新 Theme.swift 天蓝色主色调
  - [x] 1.1: 修改 HarborColors.dark 的 accent 为 `Color(red: 0.31, green: 0.76, blue: 0.97)` (#4FC3F7)
  - [x] 1.2: 修改 HarborColors.dark 的 accentDim 为 `Color(red: 0.16, green: 0.71, blue: 0.96)` (#29B6F6)
  - [x] 1.3: 修改 HarborColors.light 的 accent 为 `Color(red: 0.01, green: 0.53, blue: 0.82)` (#0288D1)
  - [x] 1.4: 修改 HarborColors.light 的 accentDim 为 `Color(red: 0.01, green: 0.47, blue: 0.74)` (#0277BD)

- [x] Task 2: HarborApp.swift 设置 NSPopover 毛玻璃背景
  - [x] 2.1: 设置 popover 内容视图的 appearance 以支持毛玻璃材质
  - [x] 2.2: 确保 NSHostingController 背景透明以透出毛玻璃效果

- [x] Task 3: MainView.swift 背景改为毛玻璃 + Header 布局重构
  - [x] 3.1: 将 `.background(theme.surface)` 改为 `.background(.ultraThinMaterial)`
  - [x] 3.2: 重构 Header 为左标题+右按钮组布局
  - [x] 3.3: Filter 改为按钮，添加 `@State private var showSearch` 控制展开/收起
  - [x] 3.4: 搜索框展开时在 Header 行内显示，带宽度动画
  - [x] 3.5: 筛选按钮图标在 magnifyingglass/xmark 间切换
  - [x] 3.6: 按钮样式统一为半透明背景、无描边

- [x] Task 4: ServiceListRowView.swift 项目分组头部改为标签式
  - [x] 4.1: 移除 ProjectGroupHeaderView 的圆角矩形背景和描边
  - [x] 4.2: 调整间距和字体，保持纯文字标签式风格

- [x] Task 5: ServiceListRowView.swift 启动按钮合并为弹出菜单
  - [x] 5.1: 将 idleFavoriteButtons 中的终端启动和后台启动合并为一个 play.circle 按钮
  - [x] 5.2: 点击启动按钮弹出 Menu，包含 "Launch in Terminal" 和 "Launch in Background" 两个选项
  - [x] 5.3: 移除 isLaunchBgHovered 状态（不再需要单独的后台启动按钮悬停状态）

- [x] Task 6: ServiceListRowView.swift 卡片阴影和间距优化
  - [x] 6.1: 为 ServiceRowContent 添加微妙阴影（radius 3, y: 1, opacity 0.1）
  - [x] 6.2: 悬停时阴影增强（radius 5, y: 2, opacity 0.15）
  - [x] 6.3: 调整内容区域水平内边距（12→14）

# Task Dependencies
- Task 1 无依赖，可先行
- Task 2 无依赖，可先行
- Task 3 依赖 Task 1（需要新色值）和 Task 2（需要毛玻璃设置）
- Task 4 依赖 Task 1（需要新色值）
- Task 5 无依赖，可先行
- Task 6 依赖 Task 1（需要新色值）
