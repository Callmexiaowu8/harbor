# 修复后台启动按钮与命令执行环境 Spec

## Why
后台启动按钮使用了图标+文字标签，导致页面排版问题；后台启动使用 `/bin/zsh -c` 执行命令，但非登录、非交互式 shell 不会加载用户 PATH（如 nvm/fnm 管理的 npm），导致 `command not found: npm` 错误。即使添加 `-l`（登录 shell）也不够，因为 nvm 初始化代码在 `~/.zshrc` 中，只有交互式 shell 才会加载。

## What Changes
- 将后台启动和终端启动按钮改为纯图标样式，移除文字标签，恢复与编辑/终止按钮一致的图标按钮风格
- 修改 `ServiceLaunchService.launchInBackground`，使用登录+交互式 shell（`/bin/zsh -l -i -c`）执行命令，确保加载用户完整的 PATH 环境变量（包括 `~/.zshrc` 中 nvm/fnm 等初始化的路径）

## Impact
- Affected code: `ServiceListRowView.swift`（按钮 UI 修改）、`ServiceLaunchService.swift`（命令执行修改）
- Affected specs: `add-background-launch`、`fix-nohup-command`

## ADDED Requirements

### Requirement: 后台启动按钮使用纯图标
系统 SHALL 使用纯图标展示终端启动和后台启动按钮，不包含文字标签，保持与行内其他操作按钮一致的视觉风格。

#### Scenario: 收藏但未运行的服务行按钮展示
- **WHEN** 收藏服务处于未运行状态
- **THEN** 显示三个图标按钮：终端启动（`apple.terminal`）、后台启动（`play.fill`）、编辑（`pencil.circle`），无文字标签

### Requirement: 后台启动使用登录+交互式 shell
系统 SHALL 使用登录+交互式 shell（`/bin/zsh -l -i`）执行后台启动命令，确保加载用户的完整 PATH 环境变量。

#### Scenario: 启动命令依赖 nvm/fnm 管理的 npm
- **WHEN** 启动命令为 `PORT=3001 npm run dev`，npm 通过 nvm/fnm 安装
- **THEN** 后台启动通过 `/bin/zsh -l -i -c "nohup /bin/zsh -c 'PORT=3001 npm run dev'"` 执行，登录+交互式 shell 加载 `~/.zprofile` 和 `~/.zshrc` 中的 PATH，npm 可被正确找到

#### Scenario: 启动命令包含变量赋值
- **WHEN** 启动命令为 `PORT=3001 npm run dev`
- **THEN** 实际执行 `nohup /bin/zsh -c 'PORT=3001 npm run dev'`，变量赋值在子 shell 中正确解析

## MODIFIED Requirements
无

## REMOVED Requirements
无
