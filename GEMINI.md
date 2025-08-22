Windows 桌宠模拟器 — 代码规范

---

#### 1. 通用原则

- **清晰性优先**：代码应自解释，变量和函数名应清晰地反映其目的。
- **一致性**：遵循 Godot 的 GDScript 编程风格，例如使用蛇形命名法（snake_case）。
- **注释**：所有公共函数、复杂代码块及非自解释的行，必须附带中文注释。注释应说明代码的用途、参数、返回值及潜在的副作用。

---

#### 2. 核心脚本规范

##### res://scripts/pet_script.gd

- **文件头部**：文件顶部应包含文件描述、作者信息及简要的许可证说明。
- **变量定义**：所有公开变量（@export）和私有变量都应有类型提示，并附带注释说明其用途。
  示例：
  # 拖动状态标志，用于判断窗口是否处于拖动模式
  var _is_dragging: bool = false
  # 鼠标在窗口内的偏移量，用于拖动计算
  var _drag_offset: Vector2 = Vector2.ZERO
- **函数定义**：所有公共函数（func）应在函数名前有一段描述性注释。
  示例：
  # 根据给定的配置字典，统一应用宠物的动画设置
  # 参数：config - 包含所有动画参数的字典
  func apply_animation_config(config: Dictionary):
      # ... 函数体 ...
- **行级注释**：对于复杂或关键的单行代码，应在行尾添加简短的注释。
  示例：
  # 遍历配置中的所有动画
  for anim_name in config.keys():
      # 如果动画存在，则更新其纹理
      if animated_sprite.frames.has_animation(anim_name):
          # 从配置中获取纹理路径并加载资源
          var texture_path = config[anim_name].get("texture", "")
          var texture = ResourceLoader.load(texture_path)
          # 设置动画的第一帧纹理
          animated_sprite.frames.set_frame_texture(anim_name, 0, texture)
      else:
          # 如果动画不存在，则打印警告信息
          print("Warning: Animation '%s' not found." % anim_name)
- **异步处理**：对于 async / await 模式，应明确注释其协程流。
- **错误处理**：对于可能失败的操作（如文件加载、资源保存），必须检查返回值并进行适当的错误处理，用注释说明错误码的含义。

---

#### 3. 配置与资源

- **配置文件**：settings.cfg 应清晰分节，每节下的键名应具有描述性。
  示例：
  [animations.initial]
  # 初始动画的雪碧图纹理路径
  texture="res://assets/animations/initial.png"
  # 水平帧数
  hframes=1
  # 垂直帧数
  vframes=1
- **资源路径**：在脚本中应使用 res:// 或 user:// 的绝对路径，避免使用相对路径。

---

#### 4. 自动化任务脚本

- **独立性**：自动化脚本应独立于主游戏逻辑，通过调用 pet_script.gd 的公共 API 来完成任务。
- **参数化**：应尽量将可变参数（如文件路径、缩放值）作为脚本的导出变量或命令行参数，方便调整。
- **输出**：脚本应提供清晰的控制台输出，包括任务开始、完成和任何错误信息。