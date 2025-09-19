# scripts/core/interfaces.gd
# 该文件定义了项目中使用的各种接口类和基类。
# 这些类本身不包含具体实现，而是用于规范其他类的行为和属性。

# ==================== 可配置接口 ====================
## @class_name IConfigurable
## 可配置接口，任何需要从 ConfigManager 加载或应用配置的类都应继承此类。
class IConfigurable:
	## 一个必须被子类重写的方法，用于应用配置。
	## @param config: (ConfigFile) 传入的配置对象。
	func apply_config(_config: ConfigFile):
		# 使用 push_error 来提示子类必须实现这个方法。
		push_error("IConfigurable.apply_config() 必须由子类实现。")


# ==================== 可拖动接口 ====================
## @class_name IDraggable
## 可拖动接口，定义了拖动行为所需的方法。
class IDraggable:
	## 当拖动开始时调用的方法。
	func on_drag_start():
		# 提示子类需要实现此方法。
		push_error("IDraggable.on_drag_start() 必须由子类实现。")
	
	## 在拖动过程中持续调用的方法。
	## @param motion: (Vector2) 鼠标或触摸的移动向量。
	func on_drag_move(_motion: Vector2):
		# 提示子类需要实现此方法。
		push_error("IDraggable.on_drag_move() 必须由子类实现。")
	
	## 当拖动结束时调用的方法。
	func on_drag_end():
		# 提示子类需要实现此方法。
		push_error("IDraggable.on_drag_end() 必须由子类实现。")


# ==================== 状态机接口 ====================
## @class_name IStateMachine
## 状态机接口，定义了状态机的基本行为。
class IStateMachine:
	## 进入一个新状态时调用的方法。
	## @param state_name: (String) 要进入的状态的名称。
	## @param context: (Dictionary) 进入状态时可能需要的上下文信息。
	func enter_state(_state_name: String, _context: Dictionary = {}):
		# 提示子类需要实现此方法。
		push_error("IStateMachine.enter_state() 必须由子类实现。")
	
	## 退出当前状态时调用的方法。
	## @param state_name: (String) 要退出的状态的名称。
	func exit_state(_state_name: String):
		# 提示子类需要实现此方法。
		push_error("IStateMachine.exit_state() 必须由子类实现。")
	
	## 更新当前状态的逻辑，通常在 _process 或 _physics_process 中调用。
	## @param delta: (float) 帧间隔时间。
	func update_state(_delta: float):
		# 提示子类需要实现此方法。
		push_error("IStateMachine.update_state() 必须由子类实现。")
