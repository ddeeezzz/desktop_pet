# scripts/controllers/pet_controller.gd
# 宠物控制器，负责管理宠物的状态、动画和核心交互逻辑。

# ==================== 宠物控制器 ====================
## @class_name PetController
## 继承自BaseManager
extends BaseManager
class_name PetController
const Constants = preload("res://scripts/core/constants.gd")
# -------------------- 节点引用 --------------------
@onready var config_manager: ConfigManager = %ConfigManager
@onready var animation_manager: AnimationManager = %AnimationManager
@onready var sprite: AnimatedSprite2D = %Pet
@onready var cloud_sprite: AnimatedSprite2D = %Cloud
@onready var cloud_button: Button = %CloudButton
@onready var menu_node: Control = %Menu

# 输入管理器引用，由主集成脚本设置
var input_manager: InputManager


# ==================== Godot 生命周期方法 ====================

## 重写 BaseManager 的 _do_initialize 方法。
func _do_initialize():
	print("PetController: 开始初始化...")
	# 注册所有事件总线监听器。
	_register_event_listeners()

	# 应用所有与宠物相关的配置。
	_apply_config()
	# 连接所有需要的节点信号。
	_connect_signals()

	# 直接播放初始动画，因为依赖的Manager已经由MainIntegration保证初始化完成。
	_play_initial_animations()
	print("PetController: 初始化完成。")

## 注册事件监听。
func _register_event_listeners():
	print("PetController: 正在注册事件监听器...")
	# 连接 EventBus 的 animations_reloaded 信号到 _on_animations_reloaded 方法。
	EventBus.animations_reloaded.connect(_on_animations_reloaded)
	# 连接 EventBus 的 scale_changed 信号到 _on_scale_changed 方法。
	EventBus.scale_changed.connect(_on_scale_changed)
	# 连接 EventBus 的 state_changed 信号到 _on_state_changed 方法。
	EventBus.state_changed.connect(_on_state_changed)
	print("PetController: 事件监听器注册完成。")


# ==================== 公共方法 ====================

## 播放一个指定的动画。
## @param anim_name: (String) 要播放的动画的名称。
func play_animation(anim_name: String):
	print("PetController: 正在播放动画: %s" % anim_name)
	# 检查AnimationManager是否存在
	if not animation_manager:
		push_error("宠物控制器: 未找到 AnimationManager 节点！")
		return
	
	# 从动画管理器获取对应的 SpriteFrames 资源。
	var anim_frames = animation_manager.get_animation(anim_name)
	# 检查资源是否存在。
	if anim_frames:
		# 如果存在，将其赋给宠物的 sprite_frames 属性。
		sprite.sprite_frames = anim_frames
		
		# 检查动画名称是否存在于SpriteFrames中
		if anim_frames.has_animation(anim_name):
			# 播放该动画。
			sprite.play(anim_name)
		else:
			# 如果没有对应名称的动画，播放第一个可用的动画
			var animations = anim_frames.get_animation_names()
			if animations.size() > 0:
				sprite.play(animations[0])
			else:
				push_error("在 SpriteFrames 中未找到 '%s' 的任何动画" % anim_name)
	# 如果资源不存在。
	else:
		# 打印错误信息。
		push_error("动画 '%s' 无法播放。" % anim_name)


# ==================== 私有方法 ====================

## 播放初始动画。
func _play_initial_animations():
	print("PetController: 正在播放初始动画...")
	# 检查AnimationManager是否存在
	if not animation_manager:
		push_error("PetController: AnimationManager node not found!")
		return
	
	# 检查AnimationManager是否已经加载了动画
	var cloud_frames = animation_manager.get_animation("anim_cloud")
	var initial_frames = animation_manager.get_animation("anim_initial")

	if cloud_frames and initial_frames:
		# 设置云朵动画但不立即播放，避免在隐藏状态下播放导致显示时从最后一帧开始
		cloud_sprite.sprite_frames = cloud_frames
		if cloud_frames.has_animation("anim_cloud"):
			cloud_sprite.animation = "anim_cloud"
			cloud_sprite.frame = 0
			cloud_sprite.stop()
		else:
			var animations = cloud_frames.get_animation_names()
			if animations.size() > 0:
				cloud_sprite.animation = animations[0]
				cloud_sprite.frame = 0
				cloud_sprite.stop()
		
		# 设置和播放宠物的初始动画
		sprite.sprite_frames = initial_frames
		if initial_frames.has_animation("anim_initial"):
			sprite.play("anim_initial")
		else:
			var pet_animations = initial_frames.get_animation_names()
			if pet_animations.size() > 0:
				sprite.play(pet_animations[0])
	else:
		# 此处现在可以安全地报错，因为初始化顺序得到保证
		if not cloud_frames:
			push_error("宠物控制器: 在 AnimationManager 中未找到云动画 'anim_cloud'")
		if not initial_frames:
			push_error("宠物控制器: 在 AnimationManager 中未找到初始动画 'anim_initial'")

## 应用所有与宠物相关的配置。
func _apply_config():
	print("PetController: 正在应用宠物配置...")
	# 检查配置管理器是否存在
	if not config_manager:
		push_error("宠物控制器: 未找到 ConfigManager 节点！")
		return
	
	# 从配置管理器获取宠物相关的配置字典。
	var pet_config = config_manager.get_section_as_dict("pet")
	# 获取缩放值，如果不存在则使用常量中定义的默认值。
	var scale_value = pet_config.get("scale", Constants.DefaultConfig.PET_CONFIG["scale"])
	# 将缩放值应用到宠物精灵节点上。
	sprite.scale = Vector2(scale_value, scale_value)

## 连接所有需要的信号。
func _connect_signals():
	print("PetController: 正在连接信号...")
	# 将宠物精灵的 animation_finished 信号连接到 _on_animation_finished 方法。
	sprite.animation_finished.connect(_on_animation_finished)
	# 将云朵按钮的 pressed 信号连接到 _on_cloud_button_pressed 方法。
	cloud_button.pressed.connect(_on_cloud_button_pressed)
	print("PetController: 信号连接完成。")


# ==================== 信号处理 ====================

## 当宠物动画播放完成时调用。
func _on_animation_finished():
	print("PetController: 动画播放完成: %s" % sprite.animation)
	var current_animation = sprite.animation
	
	# 特殊处理放置动画 - 循环，等待用户干扰
	if current_animation == "anim_placement":
		return
	
	# 其他动画完成后仍然回到初始动画
	play_animation("anim_initial")

## 当云朵按钮被按下时调用。
func _on_cloud_button_pressed():
	print("PetController: '云朵' 按钮被按下。")
	# 隐藏云朵。
	cloud_sprite.hide()
	# 显示主菜单。
	menu_node.show()
	
	# 通知输入管理器进入菜单模式
	if input_manager:
		input_manager.change_state(InputManager.InputState.MENU_OPEN, "菜单显示")
		print("宠物控制器：菜单已显示，输入状态切换到菜单模式")

## 当动画被重新加载时调用。
func _on_animations_reloaded():
	print("PetController: 动画已重新加载。")
	# 重新播放当前正在播放的动画，以应用新的动画数据。
	var current_anim_name = sprite.animation
	
	# 强制重置AnimatedSprite2D的所有内部状态
	sprite.stop()
	sprite.frame = 0
	await get_tree().process_frame
	
	# 直接使用当前动画名称，因为它已经包含完整的前缀
	if current_anim_name and current_anim_name != "":
		play_animation(current_anim_name)
		
		# 等待一帧确保动画开始播放
		await get_tree().process_frame
		
		# 关键修复 - 通过添加和删除一个“欺骗帧”来强制刷新AnimatedSprite2D的内部计时器，实现平滑过渡
		var total_frames = sprite.sprite_frames.get_frame_count(current_anim_name)
		# 仅当动画不只有一帧时才执行此操作
		if total_frames > 1:
			# 1. 复制第0帧的数据
			var frame_0_texture = sprite.sprite_frames.get_frame_texture(current_anim_name, 0)
			var frame_0_duration = sprite.sprite_frames.get_frame_duration(current_anim_name, 0)
			
			# 2. 在末尾添加这个复制帧作为“欺骗帧”
			sprite.sprite_frames.add_frame(current_anim_name, frame_0_texture, frame_0_duration)
			
			# 3. 立即跳转到这个欺骗帧（视觉上无变化）
			sprite.frame = total_frames
			
			# 4. 等待一帧，让引擎刷新状态
			await get_tree().process_frame
			
			# 5. 跳回真正的第0帧
			sprite.frame = 0
			
			# 6. 移除欺骗帧，恢复动画原始状态
			sprite.sprite_frames.remove_frame(current_anim_name, total_frames)
	else:
		# 如果没有当前动画，播放默认的初始动画
		play_animation("anim_initial")

## 当缩放比例发生变化时调用。
## @param new_scale: (float) 新的缩放值。
func _on_scale_changed(new_scale: float):
	print("PetController: 缩放比例改变为: %f" % new_scale)
	# 创建一个 Vector2 对象来表示新的缩放。
	var new_scale_vec = Vector2(new_scale, new_scale)
	# 将新的缩放应用到宠物精灵节点。
	sprite.scale = new_scale_vec

## 当宠物状态发生变化时调用。
## @param old_state: (String) 旧状态。
## @param new_state: (String) 新状态。
func _on_state_changed(_old_state: String, new_state: String):
	print("PetController: 宠物状态从 '%s' 改变为 '%s'" % [_old_state, new_state])
	# 根据新状态播放相应的动画
	# 在这里将纯粹的状态名（如 "initial"）转换为动画名（"anim_initial"）
	play_animation("anim_" + new_state)
