# scripts/components/draggable.gd
# 一个可拖动组件，可以附加到任何 Control 或 Node2D 节点上，使其能够被鼠标拖动来移动其父窗口。

# ==================== 可拖动组件 ====================
## @class_name Draggable
## 提供拖动功能的组件类。
extends Node
class_name Draggable

# -------------------- 信号 --------------------
## 当拖动开始时发出
signal drag_started
## 当拖动结束时发出
signal drag_ended

# -------------------- 导出变量 --------------------
## 是否启用拖动功能。可以通过检查器面板进行开关。
@export var enabled: bool = true

# -------------------- 私有变量 --------------------
## 一个布尔标志，用于跟踪当前是否处于拖动状态。
var _is_dragging: bool = false
var local_mouse_position
## 持有对该组件所附加到的节点的引用。
var _parent_node: Node
## 输入管理器引用，用于状态协调
var input_manager: InputManager


# ==================== Godot 生命周期方法 ====================

## _ready() 方法，在节点准备好时被调用一次。
func _ready():
	# 获取该组件节点的父节点，即组件所附加到的节点。
	_parent_node = get_parent()
	# 检查父节点是否是一个有效的 Control 或 Node2D 节点。
	if not (_parent_node is Control or _parent_node is Node2D):
		# 如果不是，则禁用此组件并打印错误信息。
		enabled = false
		# 使用 push_error 报告错误。
		push_error("可拖动组件只能附加到 Control 或 Node2D 节点上。")

## _input() 方法，用于处理输入事件。
## @param event: (InputEvent) 传入的输入事件对象。
func _input(event: InputEvent):
	# 如果拖动功能被禁用，或者父节点无效，则不处理任何输入。
	if not enabled or not _parent_node:
		# 提前退出函数。
		return

	# 检查事件是否是鼠标按钮事件。
	if event is InputEventMouseButton:
		# 检查是否是鼠标右键按下的事件。
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# 调用 _on_drag_start 方法，开始拖动处理。
			_on_drag_start(event.global_position)
		# 检查是否是鼠标右键松开的事件。
		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			# 调用 _on_drag_end 方法，结束拖动处理。
			_on_drag_end()
	
	# 检查事件是否是鼠标移动事件。
	if event is InputEventMouseMotion:
		# 调用 _on_drag_move 方法，处理拖动过程中的移动。
		_on_drag_move(event.global_position)

# ==================== 拖动逻辑 ====================

## 处理拖动开始的逻辑。
## @param mouse_position: (Vector2) 鼠标当前的全局位置。
func _on_drag_start(mouse_position: Vector2):
	print("拖拽组件：开始拖拽，鼠标位置：%s" % mouse_position)
	
	# 通知输入管理器进入拖拽模式
	if input_manager:
		input_manager.change_state(InputManager.InputState.DRAGGING, "用户开始拖拽窗口")
	
	# 将拖动状态标志设置为 true。
	_is_dragging = true
	local_mouse_position = mouse_position
	# 发出拖动开始信号
	drag_started.emit()
	
	print("拖拽组件：拖拽状态已激活")

## 处理拖动过程中的移动逻辑。
## @param mouse_position: (Vector2) 鼠标当前的全局位置。
func _on_drag_move(mouse_position: Vector2):
	# 检查当前是否处于拖动状态。
	if _is_dragging:
		var old_pos = get_window().position
		# 更新窗口的位置：鼠标当前位置减去之前存储的偏移量。
		get_window().position += Vector2i(mouse_position - local_mouse_position)
		
		# 每移动50像素打印一次日志，避免日志刷屏
		var movement = mouse_position - local_mouse_position
		if movement.length() > 50:
			print("拖拽组件：窗口移动 %s -> %s，移动距离：%.1f" % [old_pos, get_window().position, movement.length()])

## 处理拖动结束的逻辑。
func _on_drag_end():
	print("拖拽组件：结束拖拽")
	
	# 通知输入管理器回到正常模式
	if input_manager:
		input_manager.change_state(InputManager.InputState.NORMAL, "用户结束拖拽")
	
	# 将拖动状态标志设置回 false。
	_is_dragging = false
	# 发出拖动结束信号
	drag_ended.emit()
	
	print("拖拽组件：已回到正常状态")

## 在拖动结束后的下一帧检查鼠标位置，重新启动悬停检测。
