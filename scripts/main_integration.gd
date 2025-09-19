# scripts/main_integration.gd
# 主集成脚本，挂载在主场景的根节点上，负责初始化和协调各个管理器和控制器。

# ==================== 主集成脚本 ====================
## @class_name MainIntegration
## 继承自 Node，作为场景的根节点。
extends Node
class_name MainIntegration

# -------------------- 节点引用 --------------------
# Managers
@onready var config_manager: ConfigManager = %ConfigManager
@onready var animation_manager: AnimationManager = %AnimationManager
@onready var theme_manager: ThemeManager = %ThemeManager
@onready var ai_manager: AIManager = %AIManager

# Controllers
@onready var pet_controller: PetController = %PetController
@onready var menu_controller: MenuController = %MenuController

# UI Components
@onready var cloud_ui: AnimatedSprite2D = %Cloud
@onready var hover_detector: HoverDetector = %HoverDetector

# 输入管理器
var input_manager: InputManager


# ==================== Godot 生命周期方法 ====================

## _ready() 方法，使用 async/await 来保证确定性的初始化顺序。
func _ready() -> void:
	print("主集成: 开始应用程序初始化...")
	# 第一阶段：初始化基础管理器
	# ConfigManager 是所有其他模块的基础，必须第一个初始化。
	print("主集成: 正在初始化 ConfigManager...")
	config_manager.initialize()
	await config_manager.initialization_completed
	print("主集成: ConfigManager 初始化完成。")

	# 第二阶段：初始化依赖于配置的资源管理器
	# AnimationManager, ThemeManager, AIManager 都需要从配置中读取数据。
	print("主集成: 正在初始化 AnimationManager...")
	animation_manager.initialize()
	print("主集成: 正在初始化 ThemeManager...")
	theme_manager.initialize()
	print("主集成: 正在初始化 AIManager...")
	ai_manager.initialize()
	# 等待它们全部完成。
	await animation_manager.initialization_completed
	await theme_manager.initialization_completed
	await ai_manager.initialization_completed
	print("主集成: 资源管理器初始化完成。")

	# 第三阶段：初始化控制器
	# 控制器依赖于上述所有管理器。
	print("主集成: 正在初始化 PetController...")
	pet_controller.initialize()
	print("主集成: 正在初始化 MenuController...")
	menu_controller.initialize()
	# 等待它们全部完成。
	await pet_controller.initialization_completed
	await menu_controller.initialization_completed
	print("主集成: 控制器初始化完成。")

	# 第四阶段：所有模块都准备就绪，现在可以设置UI和连接信号
	print("主集成: 正在设置UI和窗口属性...")
	_setup_ui_and_window()
	print("主集成: UI和窗口属性设置完成。")
	
	# 第五阶段：设置输入管理系统
	print("主集成：开始设置输入管理系统...")
	_setup_input_management()


# ==================== 私有方法 ====================

## 设置窗口属性、连接信号和初始化UI状态。
func _setup_ui_and_window():
	print("主集成: _setup_ui_and_window() 开始执行。")
	# --- 初始化窗口 --- 
	# 使用窗口工具类来设置窗口的初始属性（如透明、无边框等）。
	WindowUtils.setup_desktop_pet_window(get_window())
	print("主集成: 窗口属性设置完成。")

	# --- 连接信号 ---
	# 将悬停检测器的 hover_timeout 信号连接到 _on_hover_timeout 方法。
	hover_detector.hover_timeout.connect(_on_hover_timeout)
	# 将悬停检测器的 unhover_timeout 信号连接到 _on_unhover_timeout 方法。
	hover_detector.unhover_timeout.connect(_on_unhover_timeout)
	# 将 EventBus 的 state_changed 信号连接到 _on_state_changed 方法。
	EventBus.state_changed.connect(_on_state_changed)
	# 连接退出请求信号
	EventBus.quit_requested.connect(_on_quit_requested)
	print("主集成: 信号连接完成。")

	# --- 初始化UI状态 ---
	# 初始时隐藏主菜单。
	menu_controller.menu_node.hide()
	# 初始时隐藏云朵UI。
	cloud_ui.hide()
	print("主集成: UI初始状态设置完成。")


# ==================== 信号处理 ====================

## 当悬停超时（鼠标悬停足够长时间）时调用。
func _on_hover_timeout():
	# 检查主菜单当前是否不可见。
	if not menu_controller.menu_node.visible:
		# 如果不可见，则显示云朵UI。
		cloud_ui.show()
		# 显示时从第0帧开始播放云朵动画
		cloud_ui.frame = 0
		cloud_ui.play()

## 当离开超时（鼠标离开足够长时间）时调用。
func _on_unhover_timeout():
	# 隐藏云朵UI。
	cloud_ui.hide()
	# 隐藏时停止动画播放，节省资源
	cloud_ui.stop()

## 当全局状态发生变化时调用。
## @param old_state: (String) 旧状态。
## @param new_state: (String) 新状态。
func _on_state_changed(_old_state: String, _new_state: String):
	# 在这里可以根据不同的状态变化来执行相应的逻辑。
	pass

## 当请求退出应用时调用。
func _on_quit_requested():
	# 执行实际的退出操作。
	get_tree().quit()


# ==================== 输入管理系统 ====================

## 设置输入管理系统
func _setup_input_management():
	print("主集成: _setup_input_management() 开始执行。")
	print("主集成：创建输入管理器...")
	
	# 创建并添加输入管理器
	input_manager = InputManager.new()
	input_manager.name = "InputManager"
	add_child(input_manager)
	input_manager.initialize()
	await input_manager.initialization_completed
	
	print("主集成：输入管理器初始化完成")
	
	# 查找并配置拖拽组件
	print("主集成: 正在设置拖拽组件...")
	_setup_draggable_components()
	print("主集成: 拖拽组件设置完成。")
	
	# 查找并配置悬停检测器
	print("主集成: 正在设置悬停检测器...")
	_setup_hover_detectors()
	print("主集成: 悬停检测器设置完成。")
	
	# 配置控制器引用
	print("主集成: 正在设置控制器引用...")
	_setup_controllers()
	print("主集成: 控制器引用设置完成。")
	
	print("主集成：输入管理系统设置完成")
	
	
	# 启用调试输入处理
	set_process_input(true)
	print("主集成：应用程序初始化完成 ✓")

## 设置拖拽组件
func _setup_draggable_components():
	print("主集成: _setup_draggable_components() 开始执行。")
	print("主集成：查找拖拽组件...")
	
	# 查找所有Draggable组件（通过类名）
	var draggable_nodes = []
	_find_nodes_by_class(self, "Draggable", draggable_nodes)
	
	print("主集成：找到 %d 个拖拽组件" % draggable_nodes.size())
	
	for node in draggable_nodes:
		node.input_manager = input_manager
		input_manager.register_component(node, "拖拽组件")
		print("主集成：配置拖拽组件 %s" % node.name)
	print("主集成: _setup_draggable_components() 执行完毕。")

## 设置悬停检测器
func _setup_hover_detectors():
	print("主集成: _setup_hover_detectors() 开始执行。")
	print("主集成：查找悬停检测器...")
	
	# 查找所有HoverDetector组件
	var hover_nodes = []
	_find_nodes_by_class(self, "HoverDetector", hover_nodes)
	
	print("主集成：找到 %d 个悬停检测器" % hover_nodes.size())
	
	for node in hover_nodes:
		node.input_manager = input_manager
		input_manager.register_component(node, "悬停检测器")
		print("主集成：配置悬停检测器 %s" % node.name)
	print("主集成: _setup_hover_detectors() 执行完毕。")

## 设置控制器的输入管理器引用
func _setup_controllers():
	print("主集成: _setup_controllers() 开始执行。")
	print("主集成：配置控制器输入管理器引用...")
	
	# 设置宠物控制器的输入管理器引用
	if pet_controller:
		pet_controller.input_manager = input_manager
		print("主集成：配置宠物控制器输入管理器")
	
	# 设置菜单控制器的输入管理器引用  
	if menu_controller:
		menu_controller.input_manager = input_manager
		print("主集成：配置菜单控制器输入管理器")
	print("主集成: _setup_controllers() 执行完毕。")


## 递归查找指定类的节点
## @param root: (Node) 根节点
## @param class_name: (String) 要查找的类名
## @param result: (Array) 结果数组
func _find_nodes_by_class(root: Node, _class_name: String, result: Array):
	if root.get_class() == _class_name:
		result.append(root)
	
	for child in root.get_children():
		_find_nodes_by_class(child, _class_name, result)


# ==================== 调试功能 ====================

## 处理调试快捷键
## @param event: (InputEvent) 输入事件

## 打印输入系统调试信息
func print_input_debug_info():
	print("\n=== 输入管理系统调试信息 ===")
	if input_manager:
		var state_name = input_manager._get_state_name(input_manager.current_state)
		print("当前输入状态：%s" % state_name)
		print("已注册组件数量：%d" % input_manager.registered_components.size())
		
		for i in range(input_manager.registered_components.size()):
			var component = input_manager.registered_components[i]
			if component and is_instance_valid(component):
				print("  组件 %d: %s (%s)" % [i+1, component.name, component.get_class()])
			else:
				print("  组件 %d: 无效引用" % [i+1])
		
		# 打印详细的状态历史
		input_manager.print_debug_info()
	else:
		print("输入管理器未初始化")
	print("===========================\n")
