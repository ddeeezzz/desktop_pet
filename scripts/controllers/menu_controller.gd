# scripts/controllers/menu_controller.gd
# 菜单控制器，负责管理主菜单和设置窗口的所有UI交互逻辑。

# ==================== 菜单控制器 ====================
## @class_name MenuController
## 继承自BaseManager
extends BaseManager
class_name MenuController
const Constants = preload("res://scripts/core/constants.gd")
const AIChatWindow = preload("res://scenes/ai_chat_window.tscn")

# -------------------- 节点引用 --------------------
## 管理器节点
@onready var config_manager: ConfigManager = %ConfigManager
@onready var ai_manager: AIManager = %AIManager

## 对主菜单根节点的引用。
@onready var menu_node: Control = %Menu
## 对设置窗口节点的引用。
@onready var settings_window: Window = %SettingsWindow
## 对宠物节点的引用，用于获取位置和大小信息。
@onready var pet_node: Node2D = %Pet
## 对文件选择器组件的引用。
@onready var file_selector: FileDialog = %FileDialog

# 主菜单按钮引用
@onready var settings_button: Button = %SettingsButton
@onready var close_button: Button = %CloseButton
@onready var exit_button: Button = %ExitButton
@onready var placement_button: Button = %PlacementButton
@onready var feeding_button: Button = %FeedingButton
@onready var petting_button: Button = %PettingButton
@onready var ai_chat_button: Button = %AIChatButton # 新增AI聊天按钮的引用

# 设置窗口按钮引用
@onready var change_initial_button: Button = %ChangeInitialButton
@onready var change_placement_button: Button = %ChangePlacementButton
@onready var change_feeding_button: Button = %ChangeFeedingButton
@onready var change_petting_button: Button = %ChangePettingButton
@onready var config_button: Button = %ConfigButton

# 设置窗口导航按钮引用
@onready var appearance_button: Button = %AppearanceButton
@onready var api_button: Button = %APIButton
@onready var interface_button: Button = %InterfaceButton

# 设置窗口面板引用
@onready var appearance_panel: ScrollContainer = %AppearancePanel
@onready var api_panel: ScrollContainer = %APIPanel
@onready var interface_panel: ScrollContainer = %InterfacePanel

# 缩放滑块引用
@onready var scale_slider: HSlider = %ScaleSlider

# -------------------- 私有变量 --------------------

## 用于存储当前要修改的动画的名称。
var _anim_to_change: String = ""
## AI聊天窗口的实例
var _ai_chat_window_instance: Window = null
## 输入管理器引用，由主集成脚本设置
var input_manager: InputManager


# ==================== Godot 生命周期方法 ====================

## 重写 BaseManager 的 _do_initialize 方法。
func _do_initialize():
	print("MenuController: 开始初始化...")
	# 注册事件监听器。
	_register_event_listeners()
	# 连接所有UI元素的信号。
	_connect_ui_signals()
	# 初始化UI状态。
	_initialize_ui_state()
	print("MenuController: 初始化完成。")

## 注册事件监听。
func _register_event_listeners():
	print("MenuController: 正在注册事件监听器...")
	# 连接文件选择器的信号
	file_selector.file_selected.connect(_on_file_selected)
	# 连接缩放变化信号以调整菜单位置
	EventBus.scale_changed.connect(_on_pet_scale_changed)
	# 监听状态变化，当其他动画开始时重置放置按钮
	EventBus.state_changed.connect(_on_state_changed_for_ui_sync)
	print("MenuController: 事件监听器注册完成。")


# ==================== 私有方法 ====================

## 初始化UI状态。
func _initialize_ui_state():
	print("MenuController: 正在初始化UI状态...")
	# 从配置管理器获取当前缩放值并设置到滑块
	if config_manager:
		var current_scale = config_manager.get_value("pet", "scale", Constants.AppUI.DEFAULT_SCALE)
		scale_slider.value = current_scale
		# 根据当前缩放设置菜单初始位置
		_update_menu_position(current_scale)
	print("MenuController: UI状态初始化完成。")

## 连接所有UI元素的信号。
func _connect_ui_signals():
	print("MenuController: 正在连接UI信号...")
	# --- 主菜单按钮 ---
	settings_button.pressed.connect(_on_settings_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	placement_button.pressed.connect(_on_placement_button_pressed)
	feeding_button.pressed.connect(_on_feeding_button_pressed)
	petting_button.pressed.connect(_on_petting_button_pressed)
	ai_chat_button.pressed.connect(_on_ai_chat_button_pressed)

	# --- 动画更换按钮 ---
	change_initial_button.pressed.connect(_on_change_anim_button_pressed.bind("initial"))
	change_placement_button.pressed.connect(_on_change_anim_button_pressed.bind("placement"))
	change_feeding_button.pressed.connect(_on_change_anim_button_pressed.bind("feeding"))
	change_petting_button.pressed.connect(_on_change_anim_button_pressed.bind("petting"))

	# --- 设置窗口导航按钮 ---
	appearance_button.pressed.connect(_on_appearance_button_pressed)
	api_button.pressed.connect(_on_api_button_pressed)
	interface_button.pressed.connect(_on_interface_button_pressed)

	# --- 缩放滑块 ---
	scale_slider.value_changed.connect(_on_scale_slider_changed)

	# --- 其他设置窗口控件 ---
	config_button.pressed.connect(_on_config_button_pressed)
	settings_window.close_requested.connect(_on_settings_window_close_requested)
	print("MenuController: UI信号连接完成。")


# ==================== UI 信号处理 ====================

## 当“设置”按钮被按下时调用。
func _on_settings_button_pressed():
	print("MenuController: '设置' 按钮被按下。")
	# 切换设置窗口的可见性。
	settings_window.visible = not settings_window.visible
	# 如果设置窗口变为可见。
	if settings_window.visible:
		# 使用窗口工具类来智能地定位设置窗口。
		WindowUtils.position_window_next_to(settings_window, get_window())

## 当"AI聊天"按钮被按下时调用。
func _on_ai_chat_button_pressed():
	print("MenuController: 'AI聊天' 按钮被按下。")
	# 如果窗口实例不存在，则创建它
	if not is_instance_valid(_ai_chat_window_instance):
		_ai_chat_window_instance = AIChatWindow.instantiate()
		_ai_chat_window_instance.set_ai_manager(ai_manager)
		get_tree().root.add_child(_ai_chat_window_instance)
		# 首次显示时，确保它在正确的位置
		WindowUtils.position_window_next_to(_ai_chat_window_instance, get_window())
		_ai_chat_window_instance.show()
	# 如果实例已存在，则切换其可见性
	else:
		_ai_chat_window_instance.visible = not _ai_chat_window_instance.visible
	
	# 如果窗口在这次操作后变为可见，确保它在最前端并重新定位
	if _ai_chat_window_instance.visible:
		WindowUtils.position_window_next_to(_ai_chat_window_instance, get_window())

## 当主菜单的"关闭"按钮被按下时调用。
func _on_close_button_pressed():
	print("MenuController: '关闭' 按钮被按下。")
	# 隐藏主菜单。
	menu_node.hide()
	# 通知UI可见性变化
	
	# 通知输入管理器恢复正常模式
	if input_manager:
		input_manager.change_state(InputManager.InputState.NORMAL, "菜单关闭")
		print("菜单控制器：菜单已隐藏，输入状态恢复正常模式")

## 当主菜单的“退出”按钮被按下时调用。
func _on_exit_button_pressed():
	print("MenuController: '退出' 按钮被按下。")
	# 发布一个“请求退出”的信号，而不是直接执行退出操作。
	EventBus.quit_requested.emit()

## 当放置按钮被按下时调用。
func _on_placement_button_pressed():
	print("MenuController: '放置' 按钮被按下。")
	# 只负责根据按钮的切换状态，发布对应的状态变更请求。
	if placement_button.button_pressed:
		EventBus.publish_state_change("idle", "placement")
	else:
		EventBus.publish_state_change("placement", "initial")

## 当投喂按钮被按下时调用。
func _on_feeding_button_pressed():
	print("MenuController: '投喂' 按钮被按下。")
	EventBus.publish_state_change("idle", "feeding")

## 当抚摸按钮被按下时调用。
func _on_petting_button_pressed():
	print("MenuController: '抚摸' 按钮被按下。")
	EventBus.publish_state_change("idle", "petting")

## 当任何一个“更换动画”按钮被按下时调用。
## @param anim_name: (String) 被绑定的动画名称。
func _on_change_anim_button_pressed(anim_name: String):
	print("MenuController: '更换动画' 按钮被按下，动画名称: %s" % anim_name)
	# 将要修改的动画名称存储起来。
	_anim_to_change = anim_name
	# 打开文件选择对话框
	file_selector.popup_centered()

## 当"打开配置"按钮被按下时调用。
func _on_config_button_pressed():
	print("MenuController: '打开配置' 按钮被按下。")
	# 使用 OS.shell_open 方法通过系统默认编辑器打开配置文件。
	# 先将 Godot 路径转换为系统路径
	var system_path = ProjectSettings.globalize_path(Constants.AppPaths.CONFIG_FILE_PATH)
	OS.shell_open(system_path)
	# 通知 ConfigManager 开始监听文件变化。
	config_manager.start_file_monitoring()

## 当设置窗口的关闭请求被触发时调用。
## 当设置窗口的关闭请求被触发时调用。
func _on_settings_window_close_requested():
	print("MenuController: 设置窗口关闭请求。")
	# 隐藏设置窗口。
	settings_window.hide()
	# 通知 ConfigManager 停止监听文件变化。
	config_manager.stop_file_monitoring()

## 当"形象"按钮被按下时调用。
func _on_appearance_button_pressed():
	print("MenuController: '形象' 按钮被按下。")
	_switch_settings_panel("appearance")

## 当"API"按钮被按下时调用。
func _on_api_button_pressed():
	print("MenuController: 'API' 按钮被按下。")
	_switch_settings_panel("api")

## 当"界面"按钮被按下时调用。
func _on_interface_button_pressed():
	print("MenuController: '界面' 按钮被按下。")
	_switch_settings_panel("interface")

## 切换设置面板的显示。
## @param panel_name: (String) 要显示的面板名称。
func _switch_settings_panel(panel_name: String):
	print("MenuController: 正在切换设置面板到: %s" % panel_name)
	# 隐藏所有面板
	appearance_panel.hide()
	api_panel.hide()
	interface_panel.hide()
	
	# 重置所有按钮状态
	appearance_button.button_pressed = false
	api_button.button_pressed = false
	interface_button.button_pressed = false
	
	# 显示选中的面板并设置对应按钮状态
	match panel_name:
		"appearance":
			appearance_panel.show()
			appearance_button.button_pressed = true
		"api":
			api_panel.show()
			api_button.button_pressed = true
		"interface":
			interface_panel.show()
			interface_button.button_pressed = true

## 当缩放滑块值改变时调用。
## @param new_value: (float) 新的缩放值。
func _on_scale_slider_changed(new_value: float):
	print("MenuController: 缩放滑块值改变为: %f" % new_value)
	# 通过ConfigManager保存新的缩放值
	config_manager.set_value("pet", "scale", new_value)
	# 通过EventBus发布缩放变化事件
	EventBus.scale_changed.emit(new_value)


## 当宠物缩اف发生变化时调用（用于调整菜单位置）。
## @param new_scale: (float) 新的缩放值。
func _on_pet_scale_changed(new_scale: float):
	print("MenuController: 宠物缩放变化为: %f" % new_scale)
	# 更新菜单位置以适应新的宠物大小
	_update_menu_position(new_scale)

## 根据宠物的缩放更新菜单位置。
## @param scale: (float) 宠物的当前缩放值。
func _update_menu_position(scale: float):
	print("MenuController: 正在更新菜单位置，当前缩放: %f" % scale)
	# 获取宠物的位置和缩放后的大小
	var pet_position = pet_node.position
	var pet_scale = pet_node.scale
	
	# 菜单位置：PetArea右边 + 小间距
	var menu_x = pet_position.x + Constants.AppUI.PET_AREA_BASE_SIZE.x * pet_scale.x - 20 * pet_scale.x

	# 菜单始终保持在宠物的垂直中心
	var menu_y = pet_position.y - Constants.AppUI.MENU_SIZE.y / 2
	
	# 更新菜单位置
	menu_node.position = Vector2(menu_x, menu_y)

# ==================== EventBus 信号处理 ====================

## 当状态发生变化时调用（用于同步UI状态）。
## @param _old_state: (String) 旧状态。
## @param new_state: (String) 新状态。
func _on_state_changed_for_ui_sync(_old_state: String, new_state: String):
	print("MenuController: 收到状态变更信号（UI同步） - 旧状态: %s, 新状态: %s" % [_old_state, new_state])
	# 根据应用状态，更新UI的显示
	match new_state:
		"placement":
			placement_button.text = "干扰"
			placement_button.button_pressed = true
		"initial":
			placement_button.text = "放置"
			placement_button.button_pressed = false
	
	# 当其他动画（非放置/初始状态）开始时，如果放置按钮还处于按下状态，则重置它
	if new_state not in ["placement", "initial"] and placement_button.button_pressed:
		placement_button.button_pressed = false
		placement_button.text = "放置"

## 当文件选择器选择了文件后调用。
## @param file_path: (String) 选择的文件路径。
func _on_file_selected(file_path: String):
	print("MenuController: 文件选择器选择了文件: %s" % file_path)
	# 检查是否有待更换的动画
	if not _anim_to_change.is_empty():
		# 通知 ConfigManager 更新配置值。
		config_manager.set_value(_anim_to_change, "texture", file_path)
		# 重置动画名称
		_anim_to_change = ""
