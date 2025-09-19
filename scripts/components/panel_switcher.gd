# scripts/components/panel_switcher.gd
# 一个可复用的面板切换器组件。它根据按钮的名称来显示对应的面板，并隐藏其他面板。

# ==================== 面板切换器组件 ====================
## @class_name PanelSwitcher
## 继承自 Node，作为一个逻辑组件。
extends Node
class_name PanelSwitcher

# -------------------- 导出变量 --------------------
## @export_group("Nodes")
## 需要管理的按钮数组。在检查器中，将所有用于切换的按钮拖到这里。
@export var buttons: Array[Button]
## 需要管理的面板数组。在检查器中，将所有需要被切换的面板（Control节点）拖到这里。
@export var panels: Array[Control]


# ==================== Godot 生命周期方法 ====================

## _ready() 方法，在节点准备好时被调用一次。
func _ready():
	# 检查按钮和面板数组的数量是否匹配。
	if buttons.size() != panels.size():
		# 如果不匹配，打印错误信息，因为无法建立一一对应的关系。
		push_error("面板切换器：按钮和面板的数量必须相同。")
		# 禁用该组件的逻辑处理。
		set_process(false)
		# 提前退出。
		return

	# 遍历所有的按钮。
	for button in buttons:
		# 将每个按钮的 pressed 信号连接到 _on_button_pressed 方法。
		# 使用 .bind(button) 将按钮自身作为参数传递给信号处理器。
		button.pressed.connect(_on_button_pressed.bind(button))

	# --- 初始化状态 ---
	# 检查按钮数组是否不为空。
	if not buttons.is_empty():
		# 默认选中第一个按钮，并显示对应的第一个面板。
		_on_button_pressed(buttons[0])


# ==================== 信号处理 ====================

## 当任何一个被管理的按钮被按下时调用。
## @param pressed_button: (Button) 被按下的那个按钮的实例。
func _on_button_pressed(pressed_button: Button):
	# 遍历所有的按钮和它们对应的索引。
	for i in range(buttons.size()):
		# 获取当前循环中的按钮实例。
		var button = buttons[i]
		# 获取当前循环中的面板实例。
		var panel = panels[i]
		
		# 检查当前按钮是否就是被按下的那个按钮。
		if button == pressed_button:
			# 如果是，则显示对应的面板。
			panel.show()
			# 并将按钮的 toggle_mode 状态设置为按下。
			button.button_pressed = true
		# 如果不是被按下的按钮。
		else:
			# 则隐藏对应的面板。
			panel.hide()
			# 并将按钮的 toggle_mode 状态设置为未按下。
			button.button_pressed = false
