# Tasks

- [x] Task 1: ServerProcess 模型添加 ppid 字段
  - [x] 在 ServerProcess 中添加 `let ppid: Int32` 字段
  - [x] 更新 init 方法，接受 ppid 参数
  - [x] 更新 Codable 兼容（ppid 有默认值 -1）
- [x] Task 2: ProcessDiscoveryService 获取 ppid
  - [x] 在 `parseLsofOutput` 中，对每个发现的进程调用 `ps -o ppid= -p <pid>` 获取 ppid
  - [x] 将 ppid 传入 ServerProcess 构造
- [x] Task 3: ProcessMonitorViewModel 构建分组+层级数据结构
  - [x] 定义新的展示数据结构：ProjectGroup（组头+子项列表）、ServiceRow（主进程+子进程列表）、ChildProcessRow
  - [x] 实现 `serviceListItems` 的分组逻辑：按 workingDirectory 分组，同端口父子进程合并
  - [x] 父子进程识别规则：同端口 + 子进程的 ppid 等于主进程的 pid
  - [x] 收藏服务匹配到项目组后归入对应组
- [x] Task 4: ServiceListRowView 支持项目组头和子进程缩进
  - [x] 新增项目组头视图：项目名 + 折叠/展开按钮 + 服务数量
  - [x] 主服务行添加子进程展开/折叠按钮（有子进程时显示）
  - [x] 子进程行：缩进展示，显示进程名和 PID
  - [x] 终止主进程时同时终止所有子进程
- [x] Task 5: MainView 适配新的数据结构
  - [x] 更新 ForEach 遍历逻辑，支持项目组头、服务行、子进程行三种类型
  - [x] 连接各类型行的回调
- [x] Task 6: 构建验证

# Task Dependencies
- Task 1 → Task 2 → Task 3（顺序依赖）
- Task 3 → Task 4, Task 5（Task 4 和 Task 5 可并行）
- Task 4, Task 5 → Task 6
