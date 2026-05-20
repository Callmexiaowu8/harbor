# 修复后台启动 nohup 命令解析 Bug Spec

## Why
后台启动使用 `nohup {startCommand}` 构造命令，当 startCommand 包含 shell 变量赋值（如 `PORT=3001 npm run dev`）时，nohup 将变量赋值误解析为可执行命令，导致 "No such file or directory" 错误。

## What Changes
- 修改 `ServiceLaunchService.launchInBackground` 中的命令构造方式，将 `nohup {command}` 改为 `nohup /bin/zsh -c '{command}'`，确保整个命令在子 shell 中执行

## Impact
- Affected code: `ServiceLaunchService.swift`（1 行修改）

## ADDED Requirements

### Requirement: nohup 命令构造
系统 SHALL 将 nohup 后的命令包裹在子 shell 中，确保 shell 变量赋值、管道、重定向等 shell 特性正确执行。

#### Scenario: 启动命令包含变量赋值
- **WHEN** 启动命令为 `PORT=3001 npm run dev`
- **THEN** 实际执行 `nohup /bin/zsh -c 'PORT=3001 npm run dev'`，变量赋值在子 shell 中正确解析

#### Scenario: 启动命令包含管道
- **WHEN** 启动命令为 `npm run build && npm start`
- **THEN** 实际执行 `nohup /bin/zsh -c 'npm run build && npm start'`，管道在子 shell 中正确执行

#### Scenario: 启动命令包含引号
- **WHEN** 启动命令包含单引号或双引号
- **THEN** 命令正确转义，不会因引号嵌套导致解析错误

## MODIFIED Requirements
无

## REMOVED Requirements
无
