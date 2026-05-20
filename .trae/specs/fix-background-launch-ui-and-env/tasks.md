# Tasks

- [x] Task 1: 修改 ServiceListRowView 按钮为纯图标样式
  - [x] 将终端启动按钮改为纯 `apple.terminal` 图标按钮（30x30 尺寸，与编辑按钮一致）
  - [x] 将后台启动按钮改为纯 `play.fill` 图标按钮（30x30 尺寸，与编辑按钮一致）
  - [x] 保持两个按钮的视觉区分：终端启动用描边风格，后台启动用填充风格
- [x] Task 2: 修复后台启动命令执行环境
  - [x] 修改 `ServiceLaunchService.launchInBackground` 中 Process 的 arguments，将 `["-c", ...]` 改为 `["-l", "-i", "-c", ...]`，使用登录+交互式 shell 加载完整 PATH

# Task Dependencies
- Task 1 和 Task 2 无依赖关系，可并行执行
