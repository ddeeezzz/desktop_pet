# scripts/components/hover_detector.gd
# 一个通用的悬停检测组件，可以附加到任何有碰撞体的 Area2D 节点上。
# 它管理两个计时器，一个用于延迟显示UI，另一个用于延迟隐藏UI。

# ==================== 悬停检测器组件 ====================
## @class_name HoverDetector
## 继承自 Node，作为一个逻辑组件。
extends Node
class_name HoverDetector

# -------------------- 信号 --------------------
## 当鼠标悬停达到指定时间后发出，通常用于请求显示UI。
signal hover_timeout
## 当鼠标离开达到指定时间后发出，通常用于请求隐藏UI。
signal unhover_timeout

# -------------------- 导出变量 --------------------
## 悬停计时器的等待时间（秒），即鼠标需要悬停多久才触发事件。
@export var hover_wait_time: float = 1.0
## 离开计时器的等待时间（秒），即鼠标需要离开多久才触发事件。
@export var unhover_wait_time: float = 0.8
@onready var draggable = %Draggable
# -------------------- 私有变量 --------------------
## 对悬停计时器节点的引用。
var _hover_timer: Timer
## 对离开计时器节点的引用。
var _unhover_timer: Timer
## 对父节点（必须是Area2D）的引用。
var _parent_area: Area2D
## 输入管理器引用，用于状态协调
var input_manager: InputManager
## 在这些状态下忽略悬停事件
var ignore_states: Array[int] = []


# ==================== Godot 生命周期方法 ====================

## _ready() 方法，在节点准备好时被调用一次。
func _ready():
	# 获取父节点。
	_parent_area = get_parent()
	# 检查父节点是否是 Area2D 类型。
	if not _parent_area is Area2D:
		# 如果不是，则禁用此组件并打印错误信息。
		set_process(false)
		# 报告错误。
		push_error("悬停检测器必须是 Area2D 节点的子节点。")
		# 提前退出。
		return

	# --- 初始化计时器 ---
	# 创建悬停计时器实例。
	_hover_timer = Timer.new()
	# 设置等待时间。
	_hover_timer.wait_time = hover_wait_time
	# 设置为单次触发模式。
	_hover_timer.one_shot = true
	# 将其添加为当前节点的子节点。
	add_child(_hover_timer)

	# 创建离开计时器实例。
	_unhover_timer = Timer.new()
	# 设置等待时间。
	_unhover_timer.wait_time = unhover_wait_time
	# 设置为单次触发模式。
	_unhover_timer.one_shot = true
	# 将其添加为当前节点的子节点。
	add_child(_unhover_timer)

	# --- 连接信号 ---
	# 连接父 Area2D 的 mouse_entered 信号到本脚本的 _on_mouse_entered 方法。
	_parent_area.mouse_entered.connect(_on_mouse_entered)
	# 连接父 Area2D 的 mouse_exited 信号到本脚本的 _on_mouse_exited 方法。
	_parent_area.mouse_exited.connect(_on_mouse_exited)
	# 连接悬停计时器的 timeout 信号到本脚本的 _on_hover_timer_timeout 方法。
	_hover_timer.timeout.connect(_on_hover_timer_timeout)
	# 连接离开计时器的 timeout 信号到本脚本的 _on_unhover_timer_timeout 方法。
	_unhover_timer.timeout.connect(_on_unhover_timer_timeout)
	
	# 连接拖动组件的信号，以便在拖动状态变化时响应
	if draggable:
		draggable.drag_started.connect(_on_drag_started)
		draggable.drag_ended.connect(_on_drag_ended)
	
	# 连接输入状态变化信号
	EventBus.input_state_changed.connect(_on_input_state_changed)
	print("悬停检测器：已连接输入状态变化信号")


# ==================== 信号处理 ====================

## 当鼠标进入父 Area2D 区域时调用。
func _on_mouse_entered():
	print("悬停检测器：鼠标进入区域")
	
	# 检查是否应该忽略悬停事件
	if input_manager and input_manager.current_state in ignore_states:
		var state_name = input_manager._get_state_name(input_manager.current_state)
		print("悬停检测器：当前为%s，忽略悬停事件" % state_name)
		return
	
	print("悬停检测器：开始悬停计时器，等待时间：%.1f秒" % hover_wait_time)
	# 停止离开计时器（如果它正在运行），因为鼠标已经回来了。
	_unhover_timer.stop()
	# 启动悬停计时器，开始计算悬停时间。
	_hover_timer.start()

## 当鼠标离开父 Area2D 区域时调用。
func _on_mouse_exited():
	print("悬停检测器：鼠标离开区域")
	# 停止悬停计时器，因为鼠标已经离开了。
	_hover_timer.stop()
	# 启动离开计时器，开始计算离开时间。
	_unhover_timer.start()
	print("悬停检测器：开始离开计时器，等待时间：%.1f秒" % unhover_wait_time)

## 当悬停计时器超时（达到等待时间）时调用。
func _on_hover_timer_timeout():
	print("悬停检测器：悬停时间到，发出显示信号")
	# 发出 hover_timeout 信号，通知其他节点可以显示UI了。
	hover_timeout.emit()

## 当离开计时器超时（达到等待时间）时调用。
func _on_unhover_timer_timeout():
	print("悬停检测器：离开时间到，发出隐藏信号")
	# 发出 unhover_timeout 信号，通知其他节点应该隐藏UI了。
	unhover_timeout.emit()

## 当拖动开始时调用。
func _on_drag_started():
	# 停止所有计时器
	_hover_timer.stop()
	_unhover_timer.stop()
	# 立即发出隐藏信号
	unhover_timeout.emit()

## 当拖动结束时调用。
func _on_drag_ended():
	print("悬停检测器：收到拖拽结束信号")
	# 停止离开计时器（如果它正在运行），因为鼠标已经回来了。
	_unhover_timer.stop()
	# 启动悬停计时器，开始计算悬停时间。
	_hover_timer.start()
	print("悬停检测器：拖拽结束，重新启动悬停检测")
	# 拖动结束后，如果鼠标仍在区域内，现有的逻辑会在下次鼠标移动时正确处理

## 处理输入状态变化
## @param old_state: (int) 旧状态
## @param new_state: (int) 新状态
## @param reason: (String) 变更原因
func _on_input_state_changed(old_state: int, new_state: int, reason: String):
	if not input_manager:
		return
		
	var old_name = input_manager._get_state_name(old_state)
	var new_name = input_manager._get_state_name(new_state)
	print("悬停检测器：收到状态变更 [%s] -> [%s]，原因：%s" % [old_name, new_name, reason])
	
	# 如果进入拖拽状态，立即隐藏UI并设置忽略状态
	if new_state == InputManager.InputState.DRAGGING:
		print("悬停检测器：进入拖拽状态，立即隐藏UI")
		_hover_timer.stop()
		_unhover_timer.stop()
		unhover_timeout.emit()
		ignore_states = [InputManager.InputState.DRAGGING, InputManager.InputState.MENU_OPEN]
	elif new_state == InputManager.InputState.MENU_OPEN:
		print("悬停检测器：进入菜单模式，停用悬停检测")
		_hover_timer.stop()
		_unhover_timer.stop()
		# 不发出隐藏信号，因为菜单显示时不应隐藏其他UI
		ignore_states = [InputManager.InputState.DRAGGING, InputManager.InputState.MENU_OPEN]
	elif (old_state == InputManager.InputState.DRAGGING or old_state == InputManager.InputState.MENU_OPEN) and new_state == InputManager.InputState.NORMAL:
		print("悬停检测器：退出特殊状态（%s），恢复正常悬停检测" % input_manager._get_state_name(old_state))
		ignore_states.clear()
