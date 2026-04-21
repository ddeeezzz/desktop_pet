# Desktop Pet (桌面宠物)

基于 Godot 4.4 和 .NET 8.0 开发的桌面宠物。动画系统支持外部精灵表动态加载，支持在全局 FPS 基准上自定义各帧的时长权重，并实现参数文件热重载。通过 Windows API 达成像素级透明窗口点击穿透。内置 AI 聊天接口（功能开发中）。

## 核心特性

### 配置驱动的动画系统
- **动态精灵图资源注册**：系统支持在运行时从外部配置文件（.cfg）动态检索并加载精灵图纹理，无需在编辑器内预先绑定资源，实现了表现层与逻辑层的彻底解耦。
- **精细化帧控制协议**：用户可以定义全局基础帧率（FPS），并为每一帧独立设置时长权重。通过配置特定帧的显示倍率，能够轻松实现复杂的非匀速动画效果。
- **配置实时热重载**：内置文件监听机制，当检测到动画相关的配置文件发生变更时，系统会自动重新解析并实时更新内存中的动画数据，大幅提升了美术资源的调试效率。
- **高度灵活的布局适配**：兼容多种精灵图排列方式，支持自定义水平（Hframes）与垂直（Vframes）分割参数，能够完美适配不同比例和尺寸的动画序列帧。

### 智能交互系统
- **像素级检测** - C# 调用 Windows API 实现基于透明度的智能点击穿透
- **状态机管理** - 统一的输入状态 management（正常、拖拽、菜单等）
- **组件化交互** - 拖拽、悬停检测等功能模块化设计

### 现代化架构
- **事件驱动设计** - 全局事件总线实现模块间解耦通信
- **管理器模式** - 配置、动画、AI、主题等功能独立管理
- **异步初始化** - 确保组件依赖关系和初始化顺序
- **SOLID原则** - 遵循面向对象设计原则的清晰架构

### 桌面集成
- **透明无边框窗口** - 完美融入桌面环境
- **智能点击穿透** - 根据内容自动切换窗口交互性
- **窗口置顶** - 始终显示在其他应用程序上方
- **自由拖拽** - 可在桌面任意位置移动

## 功能演示

### 主要功能
- **桌面宠物** - 多种动画状态的桌面伙伴
- **AI 聊天** - 集成智谱AI等多个AI服务提供商
- **智能交互** - 右键拖拽移动，鼠标悬停显示提示
- **配置管理** - 实时配置热重载，支持自定义设置
- **主题系统** - 可定制的界面主题和外观
- **桌面融合** - 透明窗口，智能点击穿透

### 支持的动画
- `initial` - 初始待机动画
- `placement` - 放置动画  
- `feeding` - 投喂动画
- `petting` - 抚摸动画
- `cloud` - 云朵提示动画

## 系统要求

### 运行环境
- **操作系统**: Windows 10/11
- **运行时**: .NET 8.0 Runtime
- **内存**: 建议 100MB+ 可用内存

### 开发环境
- **游戏引擎**: Godot 4.4+
- **开发框架**: .NET 8.0 SDK

## 安装与运行

### 快速开始（推荐）
1. 前往本仓库的 [Releases](https://github.com/ddeeezzz/desktop_pet/releases) 页面下载最新的发布包
2. 解压下载的压缩包
3. 双击运行 `DesktopPet.exe`

> **提示**: 发布包已包含所有必要的运行时组件，解压即用。

### 开发和自定义
如果您想修改代码或从源码构建：
1. 安装 [Godot 4.4+](https://godotengine.org/download)
2. 安装 [.NET 8.0 SDK](https://dotnet.microsoft.com/download)
3. 在 Godot 编辑器中打开 `project.godot`
4. 按 F5 运行或自行导出可执行文件

## 配置说明

### 动画配置
项目使用配置文件来定义动画，支持自定义精灵图导入：

```ini
[animation_initial]
texture="res://assets/animations/init.png"
hframes=3
vframes=2
frames=5
fps=8.0
frame_durations={"0": 2.0, "1": 1.0, "2": 2.0, "3": 1.0, "4": 10.0}
```

### AI 功能配置 (实验性功能)
AI 聊天功能目前处于开发阶段：

```ini
[ai]
enabled=false
provider="your_provider"
api_key="your_api_key_here"
model="your_model"
url="your_api_url"
```

### 宠物设置
```ini
[pet]
scale=1.0
```

### 界面设置
```ini
[interface]
theme="default"
```

配置文件位置：`%APPDATA%/DesktopPetData/settings.cfg`

## 项目结构

```
DesktopPet/
├── assets/                 # 资源文件
│   ├── animations/         # 动画精灵图
│   ├── fonts/             # 字体文件
│   └── themes/            # 主题资源
├── scenes/                # Godot 场景文件
│   ├── main_scene.tscn    # 主场景
│   └── ai_chat_window.tscn # AI 聊天窗口
├── scripts/               # 脚本文件
│   ├── core/              # 核心系统
│   ├── managers/          # 管理器类
│   ├── controllers/       # 控制器类
│   ├── components/        # UI 组件
│   ├── utils/             # 工具类
│   └── Clickthrough/      # 点击穿透功能 (C#)
└── 配置文件模板/          # 配置文件模板
```

## 核心架构

### 管理器系统 (Managers)
- **ConfigManager** - 配置文件管理
- **AnimationManager** - 动画资源管理和动态注册
- **AIManager** - AI API 交互管理（基础实现）
- **ThemeManager** - 主题管理
- **InputManager** - 输入事件管理

### 控制器系统 (Controllers)
- **PetController** - 宠物行为控制
- **MenuController** - 菜单界面控制

### 组件系统 (Components)
- **Draggable** - 拖拽功能组件
- **HoverDetector** - 悬停检测组件
- **AIChatWindow** - AI 聊天窗口组件（开发中）

## 动画系统

### 支持的动画类型
- `initial` - 初始待机动画
- `placement` - 放置动画
- `feeding` - 投喂动画
- `petting` - 抚摸动画
- `cloud` - 云朵提示动画

### 添加自定义动画
1. 将精灵图放入 `assets/animations/` 目录
2. 在配置文件中添加动画定义：
```ini
[animation_your_animation]
texture="res://assets/animations/your_sprite.png"
hframes=列数
vframes=行数
frames=总帧数
fps=帧率
frame_durations={"帧索引": 持续时间（用于确定帧长比例，缺省为1，最终帧显示时间为该值/帧率）}
```
3. AnimationManager 会自动加载并注册动画

## 开发说明

### 技术栈
- **引擎**: Godot 4.4
- **脚本**: GDScript + C# (.NET 8.0)
- **图形**: 2D 精灵动画（配置驱动）
- **网络**: HTTPRequest (AI API 调用)

### 关键特性
- **配置驱动开发** - 动画和功能通过配置文件灵活定义
- **事件总线系统** - 使用 EventBus 进行模块间通信
- **异步初始化** - 确保组件初始化顺序的正确性
- **状态机管理** - 管理宠物的不同行为状态

## 开发状态

### 已完成功能
- 基础桌面宠物系统
- 配置驱动的动画系统  
- 智能输入处理和拖拽功能
- 配置管理和热重载系统
- 悬停检测和交互提示
- 透明窗口和桌面集成
- 点击穿透技术

### 开发中功能
- AI 聊天界面完善
- AI 对话历史记录

### 计划功能
- 多宠物支持
- 更方便的配置修改
- 更多的动画导入格式
- 更多AI服务商集成
- 应用日志系统
- 插件系统

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。