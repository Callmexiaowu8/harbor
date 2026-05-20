# Tasks

- [x] Task 1: FavoriteService 添加 projectName 字段
  - [x] 新增 `var projectName: String?` 可选字段，默认 nil
  - [x] 更新 init 方法
  - [x] 更新 CodingKeys 和 Codable（向后兼容）
- [x] Task 2: ProcessMonitorViewModel 实现公共父目录分组算法
  - [x] 实现 `detectProjectRoot(for directory: String) -> String` 方法：给定 workingDirectory，返回项目根目录名
  - [x] 实现公共父目录分组算法（LCP + 下一级分组）
  - [x] 重构 `serviceListItems`：合并手动指定和自动检测的分组结果
  - [x] 仅对 count ≥ 2 的组生成 projectHeader DisplayItem
- [x] Task 3: AddServiceView 支持编辑 projectName
  - [x] 在添加/编辑服务表单中新增"项目名称"可选输入框
  - [x] 提示文字："Optional — leave empty to auto-detect"
- [x] Task 4: ServiceListRowView 适配单服务不显示组头
  - [x] 确认当 filteredItems 中不含 .projectHeader 时展示正常
  - [x] 子进程行在无组头时缩进样式自包含，无需修改
- [x] Task 5: 构建验证

# Task Dependencies
- Task 1 → Task 2（FavoriteService 字段变更后 ViewModel 才能使用）
- Task 2 → Task 4（分组逻辑确定后 UI 才能适配）
- Task 3 与 Task 2、Task 4 无强依赖，可并行
- 全部完成后 Task 5
