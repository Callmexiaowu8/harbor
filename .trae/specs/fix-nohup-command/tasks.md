# Tasks

- [ ] Task 1: 修复 nohup 命令构造
  - [ ] SubTask 1.1: 将 `process.arguments = ["-c", "nohup \(startCommand)"]` 改为 `process.arguments = ["-c", "nohup /bin/zsh -c '\(escapedCommand)'"]`，其中 escapedCommand 对单引号进行转义

- [ ] Task 2: 构建验证
  - [ ] SubTask 2.1: xcodebuild 编译通过

# Task Dependencies
- [Task 2] depends on [Task 1]
