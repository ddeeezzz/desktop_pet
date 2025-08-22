# 桌宠模拟器（Desktop Pet Simulator）

一个基于 Godot 的简洁桌宠示例项目，演示多状态精灵表动画、拖拽移动、缩放控制、状态机与配置保存。代码结构和行为以 `res://scripts/` 下的脚本为主，运行时会读取并写入 `user://setting.json` 作为持久化配置。

主要特性

- 多状态动画：INITIAL / PLACEMENT / FEEDING / PETTING
- 精灵表（Sprite2D）按状态显示与动画播放
- 窗口/宠物拖拽支持（可拖动窗口以移动桌宠）
- 缩放控制并保存到用户配置
- 动态加载与保存动画纹理与参数
- 简单音效管理：按状态播放对应音效

快速开始

1. 安装 Godot 4.x（推荐最新稳定版）。
2. 在 Godot 中打开本项目根目录（包含 `project.godot`）。
3. 打开场景 `res://scenes/main_scene.tscn` 并运行。

项目运行时数据

- 运行时配置文件（读写）：`user://settings.cfg`（若不存在，会从 `res://data/settings.cfg` 复制一份作为模板）
- 配置格式：使用 Godot 的 ConfigFile（*.cfg），采用节（section）与键值对保存设置，而非 JSON。
- 推荐 cfg 结构示例：

```
[pet]
scale=1.0

[animations.initial]
texture="res://assets/animations/initial.png"
hframes=1
vframes=1

[animations.placement]
texture="res://assets/animations/placement.png"
hframes=1
vframes=1
```

说明：
- `pet.scale`（在 `[pet]` 节）用于保存宠物缩放。
- 每个动画使用单独节（如 `[animations.initial]`）保存 `texture`、`hframes`、`vframes` 等参数。
- `pet_script.gd` 中的加载/保存函数应使用 `ConfigFile` 读写 `user://settings.cfg`。

场景与节点（重要路径）

- 主场景：`/root/MainScene`（节点名 MainScene）
  - `/root/MainScene/Pet`（脚本：`res://scripts/pet_script.gd`）
    - 子节点（Sprite2D 或帧动画节点）：`Initial`, `Placement`, `Feeding`, `Petting`
    - `AnimationPlayer`（包含与状态同名的动画轨道）
  - `/root/MainScene/SoundManager`（脚本：`res://scripts/sound_manager.gd`）
    - 子节点（AudioStreamPlayer）：`AudioInitial`, `AudioPlacement`, `AudioFeeding`, `AudioPetting`

重要脚本与 API 摘要

- res://scripts/pet_script.gd
  - 负责：加载/应用动画配置、管理状态显示、拖拽/窗口移动、缩放保存、运行时纹理更新
  - 常用方法：
    - change_state(state: String)
      - 切换状态（"INITIAL" / "PLACEMENT" / "FEEDING" / "PETTING"），显示对应 Sprite、播放 AnimationPlayer 中同名动画并调用 SoundManager 播放音效
    - set_scale_value(value: float)
      - 设置宠物缩放（限制在 [0.1,10]），并保存到 `user://setting.json`
    - update_animation_texture(anim_name: String, texture_path: String)
      - 在运行时为指定状态加载纹理并保存路径到配置
    - get_animation_config() -> Dictionary
      - 返回当前加载的配置字典，供 UI 使用
    - update_and_save_animation_param(anim_name: String, param: String, value)
      - 更新单个动画参数并应用与保存
  - 配置加载/保存函数：
    - _load_settings()：读取 `user://setting.json`（若不存在，复制 `res://data/setting.json`），并把纹理、hframes/vframes、scale 等应用到节点
    - _save_settings()：把当前配置序列化并写回 `user://setting.json`

- res://scripts/sound_manager.gd
  - 负责：按状态播放对应音效
  - 节点结构（在 MainScene 下）：
    - SoundManager (Node)
      - AudioInitial (AudioStreamPlayer)
      - AudioPlacement (AudioStreamPlayer)
      - AudioFeeding (AudioStreamPlayer)
      - AudioPetting (AudioStreamPlayer)
  - API：
    - play_for_state(state: String)
      - 接受 state 字符串："INITIAL" | "PLACEMENT" | "FEEDING" | "PETTING"，会调用对应子节点的 play()

资源位置

- 精灵表和静态素材：`assets/animations/`（包含 placement.png、feeding.png、petting.png 等）
- 音效资源：`assets/sounds/*.mp3`（项目中有占位 MP3，可替换为实际音效）
- 模板配置：`res://data/setting.json`

常见修改与扩展

- 添加/替换动画纹理：通过 `pet_script.gd` 的 `update_animation_texture()` 在运行时加载并保存路径，或直接在 `res://data/setting.json` 修改并重启运行时生效
- 新增状态：需要：
  1. 在场景中添加对应的 Sprite2D 节点并命名（与脚本中的映射一致）
  2. 在 `AnimationPlayer` 中添加同名动画轨道（可选）
  3. 在 `pet_script.gd` 的映射表中加入新的状态键与节点名
  4. 在 `sound_manager.gd` 中添加对应的 AudioStreamPlayer 节点并在 play_for_state 中处理

调试提示

- 若纹理未显示，检查 `user://setting.json` 中的路径是否有效，或检查该资源是否可由 ResourceLoader.load() 正确加载
- 若音效不播放，确认 `SoundManager` 节点存在于场景树的 `/root/MainScene` 下，且子节点已正确设置 AudioStream
- 拖拽窗口功能在 Windows 上通过设置 `OS.window_move` 或直接设置 `get_window().position` 实现，确保输入事件未被 GUI 拦截

贡献与许可

项目采用 MIT 许可证；欢迎提交 Issue 或 Pull Request 来改进动画配置、UI、音效和配置持久化策略。
