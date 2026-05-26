# Popover 页面视觉重设计 Spec

## Why
当前 popover 页面视觉风格偏暗沉（墨绿色调），缺少通透感和现代感。功能已完善，需要通过视觉升级提升整体品质感，包括毛玻璃效果、天蓝色主色调、更清晰的排版和更优雅的交互方式。

## What Changes
- Popover 整体背景改为半透明毛玻璃材质（`.ultraThinMaterial`）
- 主色调从墨绿/青色改为亮天蓝色（`#4FC3F7` 系列）
- Header 区域重新布局：左标题+右按钮组，更紧凑统一
- Filter 从内联搜索框改为按钮，点击后在 Header 行内展开搜索框
- 项目分组头部从卡片式改为可折叠标签式（纯文字+折叠箭头，无背景卡片）
- 服务行卡片间距和信息层级优化
- 内容区域边距调整
- 终端启动和后台启动合并为一个按钮，点击后弹出菜单选择
- 更精致的阴影处理

## Impact
- Affected specs: shorten-filter-bar（Filter 交互方式完全改变）
- Affected code:
  - `HarborApp.swift` — NSPopover 背景材质设置
  - `Theme.swift` — accent 色值更新为天蓝色系
  - `MainView.swift` — Header 布局重构、Filter 交互改为按钮+展开、背景改为毛玻璃
  - `ServiceListRowView.swift` — 项目分组头部样式、启动按钮合并为弹出菜单、卡片阴影

## ADDED Requirements

### Requirement: 毛玻璃背景
Popover 整体背景 SHALL 使用 `.ultraThinMaterial` 半透明毛玻璃材质，替代当前不透明的 `theme.surface` 纯色背景。

#### Scenario: Popover 显示毛玻璃效果
- **WHEN** popover 打开
- **THEN** 整体背景呈现半透明毛玻璃质感，可隐约透视后方内容
- **AND** 服务行卡片等子元素保持不透明背景，确保内容可读性

#### Scenario: 毛玻璃效果与主题适配
- **WHEN** 用户切换浅色/深色主题
- **THEN** 毛玻璃材质自动适配系统外观，浅色下偏白半透明，深色下偏暗半透明

### Requirement: 天蓝色主色调
系统 SHALL 将 accent 主色调从墨绿/青色改为亮天蓝色系列。

#### 色值定义
| Token | Dark Mode | Light Mode |
|-------|-----------|------------|
| `accent` | `#4FC3F7` (亮天蓝) | `#0288D1` (深天蓝) |
| `accentDim` | `#29B6F6` (中天蓝) | `#0277BD` (更深天蓝) |

#### Scenario: 天蓝色应用于所有 accent 场景
- **WHEN** 任何使用 `theme.accent` 的 UI 元素渲染
- **THEN** 显示天蓝色而非原来的墨绿/青色
- **AND** 包括：运行指示条、星标图标、端口徽章、按钮悬停高亮、确认按钮等

### Requirement: Header 区域重新布局
Header SHALL 采用左标题+右按钮组的布局，按钮组更紧凑统一。

#### 布局结构
```
[标题 + 状态指示]  ······  [筛选按钮] [主题] [添加] [刷新] [退出]
```

#### Scenario: Header 正常状态
- **WHEN** popover 显示且筛选未展开
- **THEN** 左侧显示 "Harbor" 标题和活跃服务数量
- **AND** 右侧显示按钮组：筛选（magnifyingglass 图标）、主题切换、添加服务、刷新、退出
- **AND** 按钮之间间距统一（4pt），按钮样式统一（圆角矩形，无描边，半透明背景）

#### Scenario: Header 筛选展开状态
- **WHEN** 用户点击筛选按钮
- **THEN** 筛选按钮变为关闭按钮（xmark 图标）
- **AND** 在筛选按钮右侧展开搜索输入框，带动画过渡
- **AND** 搜索框自动获取焦点
- **WHEN** 用户再次点击关闭按钮或搜索框清空后按 Escape
- **THEN** 搜索框收起，恢复为仅筛选按钮状态

### Requirement: Filter 按钮化交互
Filter SHALL 从常驻内联搜索框改为按钮触发展开模式。

#### Scenario: 默认状态
- **WHEN** popover 打开
- **THEN** 仅显示一个筛选按钮（magnifyingglass 图标），不显示搜索框

#### Scenario: 展开搜索
- **WHEN** 用户点击筛选按钮
- **THEN** 搜索框在 Header 行内展开（筛选按钮右侧），带宽度动画
- **AND** 筛选按钮图标变为 xmark
- **AND** 搜索框自动获取焦点
- **AND** 搜索逻辑与现有一致（按名称、端口、命令过滤）

#### Scenario: 收起搜索
- **WHEN** 用户点击 xmark 按钮
- **OR** 搜索框有内容时按 Escape 清空并收起
- **THEN** 搜索框带动画收起，恢复为仅筛选按钮
- **AND** 搜索文本被清空，列表恢复未过滤状态

### Requirement: 项目分组头部可折叠标签式
项目分组头部 SHALL 从卡片式改为纯文字标签式，仅显示项目名称和折叠箭头，无背景卡片。

#### Scenario: 分组头部样式
- **WHEN** 项目分组头部渲染
- **THEN** 显示文件夹图标 + 项目名称（bold）+ 服务数量 + 折叠/展开箭头
- **AND** 无背景卡片、无描边、无圆角矩形
- **AND** 点击整行可折叠/展开该分组

#### Scenario: 折叠箭头交互
- **WHEN** 分组已展开，显示 `chevron.down`
- **WHEN** 分组已折叠，显示 `chevron.right`
- **AND** 点击切换折叠状态，带动画

### Requirement: 启动按钮合并为弹出菜单
终端启动和后台启动 SHALL 合并为一个启动按钮，点击后弹出菜单选择启动方式。

#### Scenario: 未运行的收藏服务显示启动按钮
- **WHEN** 收藏服务未运行
- **THEN** 操作区显示一个启动按钮（play.circle 图标）+ 编辑按钮
- **AND** 不再同时显示终端启动和后台启动两个按钮

#### Scenario: 点击启动按钮弹出菜单
- **WHEN** 用户点击启动按钮
- **THEN** 弹出一个菜单，包含两个选项：
  - "Launch in Terminal" — apple.terminal 图标
  - "Launch in Background" — play.fill 图标
- **WHEN** 用户选择其中一个
- **THEN** 执行对应的启动操作，菜单关闭

### Requirement: 更精致的阴影处理
服务行卡片 SHALL 添加微妙的阴影效果，增强层次感和现代感。

#### Scenario: 服务行卡片阴影
- **WHEN** 服务行卡片渲染
- **THEN** 卡片带有微妙阴影（radius 2-4, y offset 1-2, opacity 0.08-0.15）
- **AND** 悬停时阴影略微增强（radius 4-6, y offset 2-3, opacity 0.12-0.2）

### Requirement: 内容区域边距调整
内容区域 SHALL 调整边距以配合毛玻璃背景和新布局。

#### Scenario: 列表内容边距
- **WHEN** 服务列表渲染
- **THEN** 水平内边距适当增加（12→14），确保内容不紧贴毛玻璃边缘
- **AND** 垂直内边距保持舒适（8-10）

## MODIFIED Requirements

### Requirement: Header 按钮样式
原：每个按钮使用 `surfaceRaised` 填充 + `border.opacity(0.5)` 描边的圆角矩形
现：按钮使用半透明背景（`theme.accent.opacity(0.08)` 或 `theme.surfaceRaised.opacity(0.5)`），无描边，更轻量通透

### Requirement: HarborColors accent 色值
原：dark accent = `Color(red: 0.2, green: 0.78, blue: 0.76)` (青色), light accent = `Color(red: 0.02, green: 0.52, blue: 0.50)` (深青)
现：dark accent = `Color(red: 0.31, green: 0.76, blue: 0.97)` (#4FC3F7 亮天蓝), light accent = `Color(red: 0.01, green: 0.53, blue: 0.82)` (#0288D1 深天蓝)

### Requirement: HarborColors accentDim 色值
原：dark accentDim = `Color(red: 0.15, green: 0.55, blue: 0.54)`, light accentDim = `Color(red: 0.02, green: 0.42, blue: 0.40)`
现：dark accentDim = `Color(red: 0.16, green: 0.71, blue: 0.96)` (#29B6F6 中天蓝), light accentDim = `Color(red: 0.01, green: 0.47, blue: 0.74)` (#0277BD 更深天蓝)

### Requirement: MainView 背景
原：`.background(theme.surface)` 不透明纯色
现：`.background(.ultraThinMaterial)` 毛玻璃材质

### Requirement: ProjectGroupHeaderView 样式
原：圆角矩形卡片 + surfaceRaised 填充 + border 描边
现：纯文字标签式，无背景卡片，无描边

### Requirement: idleFavoriteButtons
原：终端启动按钮 + 后台启动按钮 + 编辑按钮，三个按钮并排
现：一个启动按钮（弹出菜单）+ 编辑按钮，两个按钮并排

## REMOVED Requirements
无
