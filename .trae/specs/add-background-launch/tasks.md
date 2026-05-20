# Tasks

- [ ] Task 1: 扩展 ServiceLaunchService 支持后台启动
  - [ ] SubTask 1.1: 新增 `launchInBackground(workingDirectory:startCommand:serviceName:) throws` 方法
  - [ ] SubTask 1.2: 使用 `Process` 类创建子进程，`currentDirectoryURL` 设为 workingDirectory
  - [ ] SubTask 1.3: 使用 `/bin/zsh -c "{command}"` 执行启动命令
  - [ ] SubTask 1.4: 创建 `~/.harbor/logs/` 目录（如不存在）
  - [ ] SubTask 1.5: 生成日志文件路径 `~/.harbor/logs/{serviceName}-{timestamp}.log`，时间戳格式 `yyyy-MM-dd_HH-mm-ss`
  - [ ] SubTask 1.6: 将 stdout 和 stderr 重定向到日志文件（FileHandle）
  - [ ] SubTask 1.7: 设置进程独立运行（process.isSProcess = true 或设置 process group）
  - [ ] SubTask 1.8: 启动进程并处理启动失败错误
  - [ ] SubTask 1.9: workingDirectory 为空时使用用户主目录

- [ ] Task 2: 扩展 ProcessMonitorViewModel
  - [ ] SubTask 2.1: 新增 `launchServiceInBackground(_ favorite: FavoriteService)` 方法
  - [ ] SubTask 2.2: 调用 ServiceLaunchService.launchInBackground，处理错误并显示 errorMessage

- [ ] Task 3: 修改 ServiceListRowView 添加后台启动按钮
  - [ ] SubTask 3.1: 新增 `onLaunchBackground` 回调参数
  - [ ] SubTask 3.2: idleFavoriteButtons 添加后台启动按钮（`play.circle.fill`），位于终端启动按钮和编辑按钮之间
  - [ ] SubTask 3.3: 添加 `isLaunchBgHovered` 悬停状态
  - [ ] SubTask 3.4: 后台启动按钮 tooltip 为 "Launch in background"

- [ ] Task 4: 修改 MainView 连接后台启动流程
  - [ ] SubTask 4.1: ServiceListRowView 的 onLaunchBackground 回调调用 viewModel.launchServiceInBackground

- [ ] Task 5: 构建验证
  - [ ] SubTask 5.1: xcodebuild 编译通过
  - [ ] SubTask 5.2: 无编译警告

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 2, Task 3]
- [Task 5] depends on [Task 4]
