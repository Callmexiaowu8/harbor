# Popover UI 细节优化 Spec

## Why
上一轮视觉重设计后，仍有多处细节需要优化：accent 色偏深、搜索框失焦不自动关闭、项目分组展示与编辑体验不足、子进程缩进不够、运行指示条不需要等。

## What Changes
- accent 色值更淡更亮（#87DEFF 系列）
- Filter 搜索框失焦后自动关闭
- 项目分组展开/收起动画改为 spring 弹簧效果
- 项目分组头部格式对齐服务行布局（标签式，左侧图标+名称+右侧信息）
- 项目分组下的服务行增加缩进，标明归属关系
- 项目分组支持编辑名称和目录（编辑按钮弹出面板）
- "N processes" 徽章与 "Port|PID" 信息同行显示
- 子进程行增加缩进并移除连接线
- 移除运行中服务左侧的彩色竖条

## Impact
- Affected specs: redesign-popover-ui（accent 色值修改、分组头部样式修改、运行指示条移除）
- Affected code:
  - `Theme.swift` — accent/accentDim 色值更新
  - `MainView.swift` — Filter 失焦关闭逻辑、分组动画
  - `ServiceListRowView.swift` — 分组头部格式、服务行缩进、子进程缩进、运行指示条移除、processes 徽章与 detailLine 同行、分组编辑功能
  - `ProcessMonitorViewModel.swift` — 分组编辑方法（renameGroup）

## ADDED Requirements

### Requirement: accent 色值更淡更亮
系统 SHALL 将 accent 主色调调整为更淡更亮的天蓝色。

#### 色值定义
| Token | Dark Mode | Light Mode |
|-------|-----------|------------|
| `accent` | `#87DEFF` (淡天蓝) | `#2196F3` (标准蓝) |
| `accentDim` | `#66D1FC` (中淡天蓝) | `#1976D2` (深蓝) |

#### Scenario: accent 色值更新
- **WHEN** 任何使用 `theme.accent` 的 UI 元素渲染
- **THEN** 显示更淡更亮的天蓝色 (#87DEFF 深色模式 / #2196F3 浅色模式)

### Requirement: Filter 搜索框失焦自动关闭
搜索框 SHALL 在失去焦点时自动关闭并清空搜索文本。

#### Scenario: 搜索框失焦关闭
- **WHEN** 搜索框处于展开状态且用户点击搜索框外的区域
- **THEN** 搜索框带动画收起
- **AND** 搜索文本被清空
- **AND** 列表恢复未过滤状态

#### Scenario: 用户主动操作不触发失焦关闭
- **WHEN** 用户在搜索框内输入文字
- **THEN** 搜索框保持展开，不因输入而关闭

### Requirement: 项目分组展开/收起 spring 动画
项目分组的展开/收起动画 SHALL 使用 spring 弹簧效果，更自然流畅。

#### Scenario: 点击分组头部展开/收起
- **WHEN** 用户点击项目分组头部
- **THEN** 分组内容展开或收起，使用 spring 动画（response: 0.35, dampingFraction: 0.8）
- **AND** 动画感觉有弹性、自然，不像线性或 easeInOut 那样机械

### Requirement: 项目分组头部对齐服务行布局
项目分组头部 SHALL 采用标签式布局，格式与服务行对齐。

#### Scenario: 分组头部布局
- **WHEN** 项目分组头部渲染
- **THEN** 布局为：左侧文件夹图标 + 项目名称（semibold）+ 服务数量 + 右侧折叠箭头
- **AND** 字体大小、间距与服务行保持一致感
- **AND** 无背景卡片、无描边
- **AND** 右侧增加编辑按钮（pencil 图标），hover 时显示

#### Scenario: 分组头部编辑按钮
- **WHEN** 鼠标悬停在分组头部
- **THEN** 编辑按钮（pencil.circle 图标）淡入显示
- **WHEN** 点击编辑按钮
- **THEN** 弹出编辑面板，可修改项目名称和目录

### Requirement: 项目分组下服务行缩进
属于项目分组的服务行 SHALL 增加左侧缩进，标明归属关系。

#### Scenario: 分组内服务行缩进
- **WHEN** 服务行属于某个项目分组
- **THEN** 该服务行左侧增加缩进（约 20pt），视觉上与分组头部形成层级关系
- **AND** 不属于任何分组的服务行保持原有缩进不变

### Requirement: 项目分组编辑功能
系统 SHALL 支持编辑项目分组的名称和目录。

#### Scenario: 编辑分组名称
- **WHEN** 用户点击分组头部的编辑按钮
- **THEN** 弹出编辑面板，显示当前项目名称和目录
- **AND** 用户可修改项目名称
- **WHEN** 用户确认保存
- **THEN** 更新该分组下所有 FavoriteService 的 `projectName` 字段为新名称
- **AND** 分组头部显示更新后的名称

#### Scenario: 编辑分组目录
- **WHEN** 用户在编辑面板中修改目录
- **THEN** 更新该分组下所有 FavoriteService 的 `workingDirectory` 字段为新目录
- **AND** 分组可能因目录变更而重新分组

### Requirement: "N processes" 徽章与 Port|PID 同行
当服务有子进程时，"N processes" 徽章 SHALL 与 Port/PID 信息在同一行显示。

#### Scenario: 有子进程的运行中服务
- **WHEN** 服务正在运行且有子进程
- **THEN** 第一行显示：服务名称 + "N processes" 徽章
- **AND** 第二行显示：Port 徽章 + PID 文字
- **AND** "N processes" 徽章位于服务名称右侧，与名称同行

#### Scenario: 有子进程的未运行收藏服务
- **WHEN** 收藏服务未运行
- **THEN** 第一行显示：服务名称
- **AND** 第二行显示：启动命令
- **AND** 不显示 "N processes" 徽章（未运行时无子进程）

### Requirement: 子进程行增加缩进并移除连接线
子进程行 SHALL 增加左侧缩进，并移除竖线连接线，用缩进本身表达层级关系。

#### Scenario: 子进程缩进
- **WHEN** 子进程行渲染
- **THEN** 左侧缩进增加（约 40pt），比当前更深
- **AND** 不显示竖线连接线（移除 Rectangle 连接线）
- **AND** 用缩进量本身表达父子层级关系

## MODIFIED Requirements

### Requirement: HarborColors accent 色值
原：dark accent = `Color(red: 0.31, green: 0.76, blue: 0.97)` (#4FC3F7), light accent = `Color(red: 0.01, green: 0.53, blue: 0.82)` (#0288D1)
现：dark accent = `Color(red: 0.53, green: 0.87, blue: 1.0)` (#87DEFF), light accent = `Color(red: 0.13, green: 0.59, blue: 0.95)` (#2196F3)

### Requirement: HarborColors accentDim 色值
原：dark accentDim = `Color(red: 0.16, green: 0.71, blue: 0.96)` (#29B6F6), light accentDim = `Color(red: 0.01, green: 0.47, blue: 0.74)` (#0277BD)
现：dark accentDim = `Color(red: 0.4, green: 0.82, blue: 0.99)` (#66D1FC), light accentDim = `Color(red: 0.1, green: 0.46, blue: 0.82)` (#1976D2)

### Requirement: ServiceRowContent 运行指示条
原：运行中的服务左侧显示 2.5pt 宽的 accent 色竖条
现：移除该竖条，不再显示

### Requirement: ProjectGroupHeaderView 布局
原：HStack(folder + name + count + Spacer + chevron)
现：HStack(folder + name + count + Spacer + editButton + chevron)，编辑按钮 hover 时显示

### Requirement: ServiceRowContent detailLine 布局
原：detailLine 独立一行，包含 portBadge + PID
现：当有子进程时，"N processes" 徽章移至服务名称同行（第一行），detailLine 仍为第二行

### Requirement: ChildProcessRowView 缩进
原：左侧 28pt 缩进 + 竖线连接线
现：左侧约 40pt 缩进，无连接线

## REMOVED Requirements

### Requirement: 运行中服务左侧彩色竖条
**Reason**: 用户明确不需要每个服务最左侧的彩色竖条
**Migration**: 直接移除 `.overlay(alignment: .leading)` 中的竖条代码
