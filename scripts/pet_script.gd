extends AnimatedSprite2D

# 宠物脚本，继承自 AnimatedSprite2D 类，用于控制宠物的动画和行为

# 定义配置文件的路径，这个文件储存了所有动画和宠物的设置
const CONFIG_FILE_PATH = "res://data/settings.cfg"

# 用于存储从配置文件加载的数据的对象
var config = ConfigFile.new()
# 用于存储解析后的动画设置
var animations_config = {}
# 用于存储解析后的宠物设置
var pet_config = {}

# 拖动状态变量，用于判断窗口是否正在被拖动
var dragging = false
# 存储鼠标在窗口内的相对位置，用于计算拖动偏移量
var local_mouse_position: Vector2

# _ready 函数在节点进入场景树时被调用，用于初始化
func _ready():
	# 加载配置文件中的设置
	load_config()
	# 根据加载的配置创建或更新动画资源
	create_animations()
	# 应用宠物的缩放设置
	apply_pet_config()

	# 设置窗口属性，使其成为一个桌宠
	#get_window().borderless = true  # 设置窗口为无边框
	#get_window().always_on_top = true  # 设置窗口总在最前
	#get_window().transparent = true  # 设置窗口背景透明
	#get_window().transparent_bg = true # 开启透明背景支持
	#get_window().mouse_passthrough = false # 关闭鼠标穿透，以便可以点击和拖动

	# 播放初始动画
	play("initial")
	
	# 连接动画完成信号
	# 当任何动画播放完毕后，它都会调用 _on_animation_finished 函数
	animation_finished.connect(_on_animation_finished)

# 动画完成时的回调函数
func _on_animation_finished():
	# 只有当当前播放的动画不是 "initial" 时，才切换回 "initial"
	# 这可以防止 "initial" 动画播放完毕后再次播放自己
	if animation != "initial":
		play("initial")

# _input 函数用于处理输入事件，如鼠标点击
func _input(event):
	# 检查事件是否是鼠标左键按下事件
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# 如果是左键按下
		if event.pressed:
			# 将拖动状态设置为真，表示开始拖动
			dragging = true
			# 记录鼠标在当前节点（窗口）内的相对位置
			local_mouse_position = get_local_mouse_position()
		else:
			# 如果是左键松开，停止拖动
			dragging = false
	# 检查事件是否是鼠标移动事件，并且拖动状态为真
	if event is InputEventMouseMotion and dragging:
		# 计算窗口的新位置
		# 将鼠标当前位置减去拖动开始时的相对位置，得到窗口的移动量
		# 注意：get_local_mouse_position() 会实时更新，所以不需要额外的变量
		# 将 Vector2 类型转换为 Vector2i 以便与窗口位置相加
		get_window().position += Vector2i(get_local_mouse_position() - local_mouse_position)
	# 检查是否是鼠标左键按下事件
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# 如果是左键按下
		if event.pressed:
			# 开始拖动
			dragging = true
			local_mouse_position = get_local_mouse_position()
		else:
			# 停止拖动
			dragging = false
	if event is InputEventMouseMotion and dragging:
		get_window().position += Vector2i(get_local_mouse_position()- local_mouse_position)

# 加载配置文件的方法
func load_config():
	# 加载指定的配置文件，如果失败则打印错误信息
	var err = config.load(CONFIG_FILE_PATH)
	if err != OK:
		print("Error loading config file: ", err)
		return # 加载失败则返回

	# 从配置文件中提取动画和宠物设置
	# get_sections 方法获取配置文件中所有区域的名称
	for section in config.get_sections():
		# 如果区域是 'pet'，单独处理
		if section == "pet":
			# 遍历该区域下的所有键值对
			for key in config.get_section_keys(section):
				pet_config[key] = config.get_value(section, key)
		else:
			# 其他区域（如 initial, feeding 等）被视为独立的动画配置
			animations_config[section] = {}
			# 遍历该区域下的所有键值对
			for key in config.get_section_keys(section):
				animations_config[section][key] = config.get_value(section, key)

# 根据配置创建动画
func create_animations():
	# 清空所有现有的动画，以便重新加载
	sprite_frames.clear_all()

	# 遍历动画配置字典
	for anim_name in animations_config:
		# 过滤掉非字典类型的条目，比如 'fps'
		if not animations_config[anim_name] is Dictionary:
			continue

		# 获取单个动画的配置
		var anim_data = animations_config[anim_name]
		# 检查必要的键是否存在
		if not anim_data.has("texture") or not anim_data.has("hframes") or not anim_data.has("vframes") or not anim_data.has("frames") or not anim_data.has("fps"): 
			continue # 如果缺少关键信息则跳过

		# 加载动画纹理（PNG图片）
		var texture = load(anim_data["texture"])
		# 获取水平和垂直方向的帧数
		var hframes = anim_data["hframes"]
		var vframes = anim_data["vframes"]
		# 获取总帧数
		var total_frames = anim_data["frames"]
		var fps = anim_data["fps"]

		# 在 SpriteFrames 中添加一个新的动画
		sprite_frames.add_animation(anim_name)
		# 设置动画的循环模式，true为循环播放
		sprite_frames.set_animation_loop(anim_name, false)
		# 设置动画的播放速度（帧率）
		sprite_frames.set_animation_speed(anim_name, fps)

		# 计算单帧的宽度和高度
		var frame_width = texture.get_width() / hframes
		var frame_height = texture.get_height() / vframes
		
		# 使用一个计数器来跟踪已添加的帧数
		var frame_count = 0
		for y in range(vframes):
			for x in range(hframes):
				# 如果已达到总帧数，则跳出循环
				if frame_count >= total_frames:
					break
					
				# 创建一个新的 AtlasTexture 来表示雪碧图中的一帧
				var frame_texture = AtlasTexture.new()
				frame_texture.atlas = texture
				frame_texture.region = Rect2(x * frame_width, y * frame_height, frame_width, frame_height)
				# 将处理好的单帧纹理添加到动画中
				sprite_frames.add_frame(anim_name, frame_texture)
				frame_count += 1
			
			if frame_count >= total_frames:
				break


# 应用宠物相关的配置，如缩放
func apply_pet_config():
	# 获取缩放值，如果未在配置中找到，则默认为1.0
	var scale_value = pet_config.get("scale", 1.0)
	# 应用缩放
	self.scale = Vector2(scale_value, scale_value)

# 公开的播放动画方法，供其他脚本（如state_machine）调用
func play_anim(anim_name):
	# 检查动画是否存在于SpriteFrames中
	if self.sprite_frames.has_animation(anim_name):
		# 播放指定的动画
		self.play(anim_name)
	else:
		# 如果动画不存在，则打印错误信息
		print("Animation not found: ", anim_name)

# 公开的更新缩放方法
func update_scale(new_scale):
	# 更新节点的缩放属性
	self.scale = Vector2(new_scale, new_scale)
	# 将新的缩放值保存到配置文件中
	config.set_value("pet", "scale", new_scale)
	config.save(CONFIG_FILE_PATH)

# 公开的重新加载配置和动画的方法
func reload_animations():
	# 重新加载配置文件
	load_config()
	# 根据新配置重新创建动画
	create_animations()
