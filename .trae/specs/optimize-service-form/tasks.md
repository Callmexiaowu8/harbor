# Tasks

- [x] Task 1: 移除 Port 相关的 UI 组件和状态管理
  - [x] 删除 `@State private var portText = ""` 状态变量（第17行）
  - [x] 移除编辑模式下的 portText 初始化（第44行）
  - [x] 删除 Port (optional) 字段组 UI（第179-194行）
  - [x] 将 Name 字段从 HStack 布局改为独立的 VStack 布局（第161-177行）

- [x] Task 2: 优化表单布局和编辑功能
  - [x] 调整 Name 字段为全宽显示，移除外层 HStack 包装
  - [x] 验证编辑模式下 Working Directory 字段可交互（允许重新选择目录）
  - [x] 确保 Start Command 和 Name 字段在编辑模式下正常可编辑

- [x] Task 3: 更新数据保存逻辑
  - [x] 修改 `saveService()` 方法，移除 port 解析逻辑（第288行）
  - [x] 创建 FavoriteService 时将 port 参数设为 nil 或使用默认值
  - [x] 验证 isValid 逻辑仍正确（不应依赖 portText）

# Task Dependencies
- [Task 2] depends on [Task 1] ✅ 已完成
- [Task 3] depends on [Task 1, Task 2] ✅ 已完成
