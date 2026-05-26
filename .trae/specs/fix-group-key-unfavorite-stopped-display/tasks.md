# Tasks

- [x] Task 1: 分组字典 key 改为目录路径
  - [x] `serviceListItems` 中 allGroups 的 key 从项目名改为实际目录路径
  - [x] manualGroups 使用 favorite 的 workingDirectory 作为 key
  - [x] autoGroups 使用公共父目录的完整路径（而非仅最后一级名称）
  - [x] ProjectGroup 的 directory 和 name 分离：directory 存路径，name 存显示名
  - [x] collapsedGroups 的 key 同步改为路径
- [x] Task 2: 排查修复取消收藏不生效问题
  - [x] 检查 ServiceRowContent confirmBar 的 unfavorite 回调链正确连接到 MainView → viewModel.removeFavorite
  - [x] 根因：`removeAll` in-place mutation 不触发 Observation，改为 `filter` + 重新赋值
  - [x] unfavoriteGroupServices 同样优化
- [x] Task 3: 修复停止服务详情行文本溢出
  - [x] detailLine 中 startCommand Text 添加 `.frame(maxWidth: .infinity, alignment: .leading)`
- [x] Task 4: 构建验证

# Task Dependencies
- Task 1、2、3 无依赖，可并行
- 全部完成后 Task 4
