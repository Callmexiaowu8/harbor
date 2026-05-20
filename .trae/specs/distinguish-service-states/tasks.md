# Tasks

- [x] Task 1: 为运行中服务添加左侧 accent 竖条指示器
  - [x] 在 ServiceListRowView 的 body 中，为运行中行添加左侧 2.5px 宽的 accent 色竖条
  - [x] 使用 overlay(alignment: .leading) 方式在行左侧渲染竖条
  - [x] 竖条圆角与行圆角一致，上下留 4pt padding

- [x] Task 2: 为收藏未运行服务降低整体透明度
  - [x] 在 ServiceListRowView 的 body 中，当 isFavorite && !isRunning 时添加 .opacity(0.6)

- [x] Task 3: 优化未运行收藏的状态图标
  - [x] 将 statusIcon 中 else 分支的实心灰色圆 Circle().fill 改为空心圆 Circle().strokeBorder
  - [x] 保持 8pt 尺寸不变

# Task Dependencies
- Task 1, 2, 3 相互独立，已全部完成 ✅
