# scripts/managers/input_manager.gd
# 输入管理器 - 统一协调所有输入处理
extends BaseManager
class_name InputManager

# 输入状态枚举
enum InputState {
	NORMAL,      # 正常状态：所有交互都可用
	DRAGGING,    # 拖拽状态：禁用悬停检测
	MENU_OPEN,   # 菜单打开：部分交互受限
	CHAT_FOCUS   # 聊天焦点：文本输入优先
}

# 当前输入状态
var current_state: InputState = InputState.NORMAL
# 已注册的输入组件列表
var registered_components: Array = []
# 状态变更历史记录
var state_change_history: Array = []

# 重写 BaseManager 的 _do_initialize 方法
func _do_initialize():
	print("输入管理器：开始初始化...")
	# 连接全局事件总线信号
	_register_event_listeners()
	print("输入管理器：初始化完成，当前状态：%s" % _get_state_name(current_state))

# 改变输入状态
## 改变输入状态
func change_state(new_state: InputState, reason: String = ""):
	print("InputManager: 正在改变状态...")
	var old_state = current_state
	current_state = new_state
	
	var old_name = _get_state_name(old_state)
	var new_name = _get_state_name(new_state)
	print("输入管理器：状态变更 [%s] -> [%s]，原因：%s" % [old_name, new_name, reason])
	
	# 记录状态变更历史
	_record_state_change(old_state, new_state, reason)
	
	# 通知所有注册的组件
	_notify_components(old_state, new_state)
	
	# 通过事件总线广播状态变化
	EventBus.input_state_changed.emit(old_state, new_state, reason)

# 注册输入组件
## 注册输入组件
func register_component(component: Node, type_name: String = ""):
	print("InputManager: 正在注册组件...")
	if component in registered_components:
		print("输入管理器：组件已注册，跳过 - %s" % component.name)
		return
	
	registered_components.append(component)
	var display_type = type_name if type_name != "" else component.get_class()
	print("输入管理器：注册组件 %s，类型：%s，总数：%d" % [component.name, display_type, registered_components.size()])
	
	# 根据组件类型进行特殊设置
	_setup_component_integration(component)

# 获取当前输入状态的中文名称
func get_current_state_name() -> String:
	return _get_state_name(current_state)

# 打印调试信息
func print_debug_info():
	print("\n=== 输入管理器调试信息 ===")
	print("当前状态：%s" % _get_state_name(current_state))
	print("已注册组件数量：%d" % registered_components.size())
	print("状态变更历史（最近5条）：")
	var start_index = max(0, state_change_history.size() - 5)
	for i in range(start_index, state_change_history.size()):
		var record = state_change_history[i]
		print("  [%d] %s -> %s (%s)" % [record.timestamp, record.old_state, record.new_state, record.reason])
	print("========================\n")

# 注册事件监听器
func _register_event_listeners():
	# 监听全局输入状态变化（主要用于调试和日志记录）
	EventBus.input_state_changed.connect(_on_global_input_state_changed)

# 获取状态的中文名称
func _get_state_name(state: InputState) -> String:
	match state:
		InputState.NORMAL:
			return "正常模式"
		InputState.DRAGGING:
			return "拖拽模式"
		InputState.MENU_OPEN:
			return "菜单模式"
		InputState.CHAT_FOCUS:
			return "聊天模式"
		_:
			return "未知模式"

# 记录状态变更历史
## 记录状态变更历史
func _record_state_change(old_state: InputState, new_state: InputState, reason: String):
	print("InputManager: 正在记录状态变更历史...")
	state_change_history.append({
		"timestamp": Time.get_ticks_msec(),
		"old_state": _get_state_name(old_state),
		"new_state": _get_state_name(new_state),
		"reason": reason
	})
	
	# 限制历史记录数量，避免内存泄漏
	if state_change_history.size() > 20:
		state_change_history.pop_front()

# 通知所有已注册的组件状态变化
func _notify_components(_old_state: InputState, _new_state: InputState):
	print("InputManager: 正在通知组件状态变化...")
	for component in registered_components:
		if component and is_instance_valid(component):
			# TODO: 如果需要直接通知组件，可以在这里添加逻辑
			# 目前通过EventBus统一通知
			pass
		else:
			# 清理无效的组件引用
			print("输入管理器：发现无效组件引用，准备清理")
			registered_components.erase(component)

# 设置组件集成
## 设置组件集成
func _setup_component_integration(component: Node):
	print("InputManager: 正在设置组件集成 - %s" % component.name)
	# 根据组件类型进行特定设置
	var _class_name = component.get_class()
	
	match _class_name:
		"Draggable":
			print("输入管理器：设置拖拽组件集成 - %s" % component.name)
		"HoverDetector":
			print("输入管理器：设置悬停检测器集成 - %s" % component.name)
		_:
			print("输入管理器：设置通用组件集成 - %s (%s)" % [component.name, _class_name])

# 处理全局输入状态变化（主要用于调试）
## 处理全局输入状态变化（主要用于调试）
func _on_global_input_state_changed(_old_state: int, _new_state: int, _reason: String):
	print("InputManager: 收到全局输入状态变化信号 - 旧状态: %s, 新状态: %s, 原因: %s" % [_old_state, _new_state, _reason])
	# 这个方法主要用于调试和监控
	# 避免重复打印日志（因为change_state已经打印过了）
	pass
