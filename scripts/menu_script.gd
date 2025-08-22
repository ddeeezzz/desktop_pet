extends Control

# UI菜单脚本，继承自 Control 类，用于管理所有UI交互

# 使用 @onready 关键字确保在调用前节点已经准备好
# 获取 Pet 节点的引用，方便后续调用其方法
@onready var pet = get_node("../Pet")
# 获取设置面板节点的引用
@onready var settings_panel = $SettingsPanel
# 获取缩放滑块节点的引用
@onready var scale_slider = $SettingsPanel/VBoxContainer/ScaleHBox/ScaleSlider
# 获取文件对话框节点的引用
@onready var file_dialog = $FileDialog

# StateMachine 引用（将在 _ready 中尝试定位）
var state_machine: Node = null

# 用于存储当前正在被修改的动画的名称，例如 "initial", "feeding" 等
var anim_to_change = ""

# _ready 函数在节点进入场景树时被调用，用于初始化
func _ready():
	# --- 连接主菜单按钮的 pressed 信号到对应的处理函数 ---
	$MainMenu/PlacementButton.pressed.connect(_on_placement_button_pressed)
	$MainMenu/FeedingButton.pressed.connect(_on_feeding_button_pressed)
	$MainMenu/PettingButton.pressed.connect(_on_petting_button_pressed)
	$MainMenu/SettingsButton.pressed.connect(_on_settings_button_pressed)

	# 尝试定位 StateMachine 节点（优先使用场景中相对路径，若未找到则尝试根路径）
	state_machine = get_node_or_null("../StateMachine")
	if not state_machine:
		state_machine = get_node_or_null("/root/MainScene/StateMachine")

	# --- 连接设置面板中控件的信号到对应的处理函数 ---
	# 连接更换"初始动画"按钮
	$SettingsPanel/VBoxContainer/GridContainer/ChangeInitialButton.pressed.connect(_on_change_anim_button_pressed.bind("initial"))
	# 连接更换"放置动画"按钮
	$SettingsPanel/VBoxContainer/GridContainer/ChangePlacementButton.pressed.connect(_on_change_anim_button_pressed.bind("placement"))
	# 连接更换"投喂动画"按钮
	$SettingsPanel/VBoxContainer/GridContainer/ChangeFeedingButton.pressed.connect(_on_change_anim_button_pressed.bind("feeding"))
	# 连接更换"抚摸动画"按钮
	$SettingsPanel/VBoxContainer/GridContainer/ChangePettingButton.pressed.connect(_on_change_anim_button_pressed.bind("petting"))

	# 连接缩放滑块的 value_changed 信号
	scale_slider.value_changed.connect(_on_scale_slider_value_changed)
	# 初始化滑块的值，使其与宠物当前的缩放值一致
	scale_slider.value = pet.scale.x

	# --- 连接文件对话框的 file_selected 信号 ---
	file_dialog.file_selected.connect(_on_file_dialog_file_selected)

# --- 主菜单按钮处理函数 ---

# “放置”按钮按下时的处理 (播放 placement 动画)
func _on_placement_button_pressed():
	# 优先通过 StateMachine 切换状态（以保证统一流程：显示/动画/音效）
	# 使用枚举值调用状态机
	state_machine.call("change_state", state_machine.States.PLACEMENT)

# “投喂”按钮按下时的处理 (播放 feeding 动画)
func _on_feeding_button_pressed():
	state_machine.call("change_state", state_machine.States.FEEDING)

# “抚摸”按钮按下时的处理 (播放 petting 动画)
func _on_petting_button_pressed():
	state_machine.call("change_state", state_machine.States.PETTING)

# “设置”按钮按下时的处理
func _on_settings_button_pressed():
	# 切换设置面板的可见性 (显示/隐藏)
	settings_panel.visible = not settings_panel.visible

# --- 设置面板处理函数 ---

# 缩放滑块值改变时的处理
func _on_scale_slider_value_changed(value):
	# 调用 pet 脚本的方法更新宠物的缩放
	pet.update_scale(value)

# “更换PNG”按钮按下时的通用处理函数
# 使用 .bind(anim_name) 将动画名称作为参数传递
func _on_change_anim_button_pressed(anim_name):
	# 记录下当前要修改的是哪个动画
	anim_to_change = anim_name
	# 弹出文件选择对话框，让用户选择文件
	file_dialog.popup_centered()

# --- 文件对话框处理函数 ---

# 当用户在文件对话框中选择一个文件后被调用
func _on_file_dialog_file_selected(path):
	# 检查 anim_to_change 是否为空，防止意外调用
	if anim_to_change.is_empty():
		return # 如果为空，则不执行任何操作

	# 从 pet 脚本获取对配置文件的引用
	var config = pet.config
	# 更新配置文件中对应动画的 texture 路径
	config.set_value(anim_to_change, "texture", path)
	# 保存对配置文件的修改
	config.save(pet.CONFIG_FILE_PATH)

	# 通知 pet 脚本重新加载所有动画以应用更改
	pet.reload_animations()

	# 重置 anim_to_change 变量，为下次操作做准备
	anim_to_change = ""
