extends Node # 状态机脚本，负责统一管理桌宠状态

enum States { PLACEMENT, FEEDING, PETTING } # 定义三种状态：初始状态、放置、投喂、抚摸

@export var pet_node: NodePath # 导出变量：指向宠物节点路径
@export var sound_manager_node: NodePath # 导出变量：指向音效管理器路径

var pet_script: Node = null # 运行时缓存宠物脚本引用
var sound_manager: Node = null # 运行时缓存音效管理器引用

func _ready() -> void: # 节点就绪时回调
	if pet_node != NodePath(""): # 若导出路径已设置
		pet_script = get_node_or_null(pet_node) # 通过路径获取宠物脚本节点
		if not pet_script:
			# 尝试在常见位置寻找 Pet 节点
			pet_script = get_node_or_null("../Pet")
			if not pet_script:
				pet_script = get_node_or_null("/root/MainScene/Pet")

	if sound_manager_node != NodePath(""):
		sound_manager = get_node_or_null(sound_manager_node)
		if not sound_manager:
			# 尝试在常见位置寻找 SoundManager 节点
			sound_manager = get_node_or_null("../SoundManager")
			if not sound_manager:
				sound_manager = get_node_or_null("/root/MainScene/SoundManager")

func change_state(new_state: int) -> void: # 对外提供的状态切换方法
	# 状态到动画名与字符串的映射
	var anim_name: String = ""
	var state_str: String = ""
	match new_state:
		States.PLACEMENT:
			anim_name = "placement"
			state_str = "PLACEMENT"
		States.FEEDING:
			anim_name = "feeding"
			state_str = "FEEDING"
		States.PETTING:
			anim_name = "petting"
			state_str = "PETTING"

	# 切换宠物动画：使用 pet_script.play_anim
	if pet_script:
		pet_script.call("play_anim", anim_name)

	# 播放对应音效（由 SoundManager 管理）	
	if sound_manager and sound_manager.has_method("play_for_state"):
		sound_manager.call("play_for_state", state_str)

	# 其他需要的扩展点（比如 UI 状态同步）可以在这里添加
