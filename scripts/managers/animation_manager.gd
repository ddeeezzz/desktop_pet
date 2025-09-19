# scripts/managers/animation_manager.gd
# 动画管理器，一个自动加载的单例，负责从配置中加载、创建和缓存动画资源。

# ==================== 动画管理器 ====================
## @class_name AnimationManager
## 继承自 BaseManager，使其拥有标准化的初始化流程。
extends BaseManager
class_name AnimationManager
const Constants = preload("res://scripts/core/constants.gd")

# -------------------- 节点引用 --------------------
@onready var config_manager: ConfigManager = %ConfigManager

# -------------------- 私有变量 --------------------
## 一个字典，用于缓存创建好的 SpriteFrames 资源，以动画名称为键。
var _animation_cache: Dictionary = {}


# ==================== Godot 生命周期方法 ====================

## 重写 BaseManager 的 _do_initialize 方法。
func _do_initialize():
	print("AnimationManager: 开始初始化...")
	# 检查是否成功获取到 ConfigManager。
	if not config_manager:
		# 如果没有，打印严重错误信息。
		push_error("AnimationManager: ConfigManager node not found!")
		# 提前退出，因为没有配置，动画管理器无法工作。
		return
	
	# 直接调用初始化动画的方法。
	_initialize_animations()
	print("AnimationManager: 初始化完成。")


# ==================== 公共方法 ====================

## 获取一个已创建的动画资源 (SpriteFrames)。
## @param anim_name: (String) 想要获取的动画的名称。
## @return: (SpriteFrames) 返回对应的 SpriteFrames 资源，如果不存在则返回 null。
func get_animation(anim_name: String) -> SpriteFrames:
	print("AnimationManager: 正在获取动画: %s" % anim_name)
	
	# 检查缓存中是否存在请求的动画。
	if _animation_cache.has(anim_name):
		# 如果存在，则从缓存中返回它。
		return _animation_cache[anim_name]
	# 如果缓存中不存在。
	else:
		# 打印警告信息。
		print("警告: 缓存中未找到动画 '%s'。可用动画: %s" % [anim_name, _animation_cache.keys()])
		# 返回 null。
		return null


# ==================== 私有方法 ====================

## 初始化动画系统。
func _initialize_animations():
	print("AnimationManager: 正在初始化动画系统...")
	# 调用 _load_all_animations 方法，在启动时加载所有动画。
	_load_all_animations()
	# 将 EventBus 的 config_changed 信号连接到 _on_config_changed 方法。
	EventBus.config_changed.connect(_on_config_changed)
	print("AnimationManager: 动画系统初始化完成。")

## 加载并创建所有在配置中定义的动画。
func _load_all_animations():
	print("AnimationManager: 正在加载所有动画...")
	# TODO: 清空旧缓存，确保重载时使用新的动画数据
	_animation_cache.clear()
	
	# 从配置管理器获取所有动画的配置数据。
	var anim_configs = config_manager.get_animation_configs()
	
	# 遍历配置中的每一个动画。
	for anim_name in anim_configs:
		# 获取该动画的具体配置字典。
		var config = anim_configs[anim_name]
		
		# 调用 _create_animation 方法来创建 SpriteFrames 资源。
		var sprite_frames = _create_animation(anim_name, config)
		# 检查动画是否创建成功。
		if sprite_frames:
			# 如果成功，将其存入缓存。
			_animation_cache[anim_name] = sprite_frames
	

## 验证动画配置的完整性和有效性。
## @param anim_name: (String) 动画的名称。
## @param config: (Dictionary) 该动画的配置数据。
## @return: (bool) 配置有效返回 true，否则返回 false。
func _validate_animation_config(anim_name: String, config: Dictionary) -> bool:
	print("AnimationManager: 正在验证动画 '%s' 的配置..." % anim_name)
	# 定义一个数组，包含创建动画所必需的键。
	var required_keys = ["texture", "hframes", "vframes", "frames", "fps"]
	# 使用验证工具检查配置是否包含所有必需的键。
	if not ValidationUtils.has_required_keys(config, required_keys):
		# 如果缺少键，打印错误信息并返回 false。
		push_error("Animation '%s' has incomplete configuration." % anim_name)
		return false

	# 获取纹理路径。
	var texture_path = config["texture"]
	# 检查纹理文件是否存在。
	if not ValidationUtils.file_path_exists(texture_path):
		# 如果不存在，打印错误信息并返回 false。
		push_error("Texture file not found for animation '%s': %s" % [anim_name, texture_path])
		return false
	
	return true

## 根据给定的配置创建一个 SpriteFrames 资源。
## @param anim_name: (String) 动画的名称。
## @param config: (Dictionary) 该动画的配置数据。
## @return: (SpriteFrames) 返回创建好的 SpriteFrames 资源，失败则返回 null。
func _create_animation(anim_name: String, config: Dictionary) -> SpriteFrames:
	print("动画管理器: 正在创建动画 '%s'，配置: %s" % [anim_name, config])
	
	# 验证配置的完整性和有效性。
	if not _validate_animation_config(anim_name, config):
		print("动画管理器: 动画 '%s' 的验证失败" % anim_name)
		return null

	# 创建一个新的 SpriteFrames 资源实例。
	var sprite_frames = SpriteFrames.new()
	# 在资源中添加一个以 anim_name 命名的动画。
	sprite_frames.add_animation(anim_name)
	print("动画管理器: 已将动画 '%s' 添加到 SpriteFrames" % anim_name)
	
	# 设置动画的播放速度。
	sprite_frames.set_animation_speed(anim_name, config["fps"])
	# 根据配置设置动画是否循环播放。
	# 使用常量定义的循环动画列表
	var default_loop = anim_name in Constants.DefaultConfig.LOOPING_ANIMATIONS
	sprite_frames.set_animation_loop(anim_name, config.get("loop", default_loop))
	print("动画管理器: 已设置动画 '%s' 速度=%.1f, 循环=%s" % [anim_name, config["fps"], config.get("loop", default_loop)])

	# 从 config 取 texture
	var texture_path = config["texture"]
	print("动画管理器: 正在从路径加载纹理: %s" % texture_path)
	var texture = load(texture_path)
	# 检查纹理是否成功加载
	if not texture:
		push_error("Failed to load texture for animation %s: %s" % [anim_name, texture_path])
		return null
	print("动画管理器: 纹理加载成功，尺寸: %dx%d" % [texture.get_width(), texture.get_height()])
	# 计算单帧的宽度。
	var frame_width = texture.get_width() / config["hframes"]
	# 计算单帧的高度。
	var frame_height = texture.get_height() / config["vframes"]
	
	# 获取自定义的帧时长配置。
	var frame_durations_raw = config.get("frame_durations", "{}")
	var frame_durations = {}
	# 如果frame_durations是字符串，则解析为字典
	if typeof(frame_durations_raw) == TYPE_STRING:
		if frame_durations_raw != "{}":
			var parsed_result = JSON.parse_string(frame_durations_raw)
			if parsed_result != null:
				frame_durations = parsed_result
			else:
				push_error("AnimationManager: Failed to parse frame_durations for '" + anim_name + "': " + str(frame_durations_raw))
	else:
		frame_durations = frame_durations_raw
	# 初始化帧计数器。
	var frame_count = 0
	# 遍历雪碧图的每一行。
	for y in range(config["vframes"]):
		# 遍历雪碧图的每一列。
		for x in range(config["hframes"]):
			# 检查是否已达到动画的总帧数。
			if frame_count >= config["frames"]:
				# 如果达到，则跳出内层循环。
				break

			# 创建一个新的 AtlasTexture 来表示雪碧图中的一帧。
			var frame_texture = AtlasTexture.new()
			# 设置其源纹理。
			frame_texture.atlas = texture
			# 设置其在源纹理中的区域。
			frame_texture.region = Rect2(x * frame_width, y * frame_height, frame_width, frame_height)
			
			# 获取当前帧的自定义时长，如果未定义则默认为1.0。
			var duration = float(frame_durations.get(str(frame_count), 1.0))
			
			
			# 将处理好的一帧添加到 SpriteFrames 资源中，并指定其时长。
			sprite_frames.add_frame(anim_name, frame_texture, duration)
			# 帧计数器加一。
			frame_count += 1
		
		# 再次检查是否已达到总帧数，以跳出外层循环。
			if frame_count >= config["frames"]:
				# 跳出外层循环。
				break

	# 显示创建完成的动画信息
	print("动画管理器: 动画 '%s' 创建成功，包含 %d 帧" % [anim_name, frame_count])
	print("动画管理器: SpriteFrames 包含动画: %s" % sprite_frames.get_animation_names())
	
	# 返回创建完成的 SpriteFrames 资源。
	return sprite_frames


# ==================== 信号处理 ====================

## 当配置文件发生变化时调用。
## @param section: (String) 变化的配置所在的节。
## @param key: (String) 变化的配置的键。
## @param old_value: (Variant) 旧值。
## @param new_value: (Variant) 新值。
func _on_config_changed(section: String, _key: String, _old_value, _new_value):
	print("AnimationManager: 收到配置变更信号。节: %s, 键: %s" % [section, _key])
	
	# TODO: 检查是否是全局重载事件
	if section == "__global__" and _key == "__reload__":
		# 全局重载，重新加载所有动画
		_load_all_animations()
		# 发出 animations_reloaded 信号，通知其他部分动画已更新。
		EventBus.animations_reloaded.emit()
		return
	
	# 检查变化的配置是否与动画相关。
	if config_manager.get_animation_configs().has(section):
		# 如果是动画相关的配置发生了变化，则重新加载所有动画。
		_load_all_animations()
		# 发出 animations_reloaded 信号，通知其他部分动画已更新。
		EventBus.animations_reloaded.emit()
