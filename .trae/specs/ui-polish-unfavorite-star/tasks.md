# Tasks

- [x] Task 1: 修改 ServiceListRowView statusIcon 支持星号取消收藏
  - [x] SubTask 1.1: 已收藏服务的 `star.fill` 从 Image 改为 Button，点击触发 `onRemoveFavorite`
  - [x] SubTask 1.2: 星号按钮添加悬停效果（透明度降低 0.6）和 tooltip "Remove from favorites"
  - [x] SubTask 1.3: idleFavoriteButtons 移除 `minus.circle` 移除按钮（由星号替代）

- [x] Task 2: 重构 detailLine 为结构化双行布局
  - [x] SubTask 2.1: 拆分为 metaLine（收藏配置：startCommand + workingDirectory）和 processLine（运行信息：command + PID + portBadge）
  - [x] SubTask 2.2: favoriteRunning 显示两行，favoriteIdle 只显示 metaLine，runningOnly 只显示 processLine
  - [x] SubTask 2.3: 各行独立使用 HStack + `·` 分隔符

- [x] Task 3: 视觉精致度优化
  - [x] SubTask 3.1: 调整图标尺寸（星号 22×22/font 13.5，操作按钮 font 14）
  - [x] SubTask 3.2: 调整卡片内间距（h-padding 16, v-padding 14, 圆角 12）
  - [x] SubTask 3.3: 调整字体层次（名称 14/semibold，详情 11，确认栏 11.5）
  - [x] SubTask 3.4: 调整边框线宽（0.75）和 hover 过渡

- [x] Task 4: 构建验证
  - [x] SubTask 4.1: `xcodebuild` 编译通过
  - [x] SubTask 4.2: 检查无编译警告

# Task Dependencies
- [Task 3] depends on [Task 1] (移除按钮后需调整操作区布局)
- [Task 4] depends on [Task 1, Task 2, Task 3]
