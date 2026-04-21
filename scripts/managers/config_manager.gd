# scripts/managers/config_manager.gd
# 配置管理器，一个自动加载的单例，负责处理所有配置文件的读写、默认值创建和文件变化监听。

# ==================== 配置管理器 ====================
## @class_name ConfigManager
## 继承自 BaseManager，使其拥有标准化的初始化流程。
extends BaseManager
class_name ConfigManager
const Constants = preload("res://scripts/core/constants.gd")
# -------------------- 私有变量 --------------------
## 一个 ConfigFile 对象实例，用于实际的配置文件操作。
var _config: ConfigFile = ConfigFile.new()
## 一个计时器，用于定期检查配置文件的修改时间。
var _file_check_timer: Timer
## 存储配置文件上一次被修改的时间戳（Unix时间）。
var _last_modified_time: int = 0
## 一个布尔标志，表示当前是否正在监听文件变化。
var _is_monitoring: bool = false


# ==================== Godot 生命周期方法 ====================

## 重写 BaseManager 的 _do_initialize 方法，实现具体的初始化逻辑。
func _do_initialize():
	print("ConfigManager: 开始初始化...")
	# 调用 load_config 方法来加载配置文件，如果文件不存在则会创建默认配置。
	load_config()
	# 自动启动文件监听，实现配置热重载
	start_file_monitoring()
	print("ConfigManager: 初始化完成。")


# ==================== 公共方法 ====================

## 加载配置文件。
func load_config():
	print("ConfigManager: 正在加载配置文件...")
	# 尝试从常量 AppPaths.CONFIG_FILE_PATH 定义的路径加载配置文件。
	var err = _config.load(Constants.AppPaths.CONFIG_FILE_PATH)
	# 检查加载操作是否成功。
	if err != OK:
		# 如果失败（例如文件不存在或格式错误），则打印警告信息。
		print("配置文件未找到或已损坏（错误码: %d），正在创建新文件。" % err)
		# 调用 _create_default_config 方法来生成一份默认配置。
		_create_default_config()
		# 调用 save_config 方法将默认配置写入磁盘。
		save_config()
	else:
		# 验证配置文件的基本结构
		_validate_config()

## 保存当前配置到文件。
func save_config():
	print("ConfigManager: 正在保存配置文件...")
	# 尝试将 _config 对象的内容保存到指定的路径。
	var err = _config.save(Constants.AppPaths.CONFIG_FILE_PATH)
	# 检查保存操作是否成功。
	if err != OK:
		# 如果失败，则使用 push_error 报告一个严重错误。
		push_error("Failed to save config file! Error code: %d" % err)

## 获取指定节和键的值。
## @param section: (String) 配置中的节名。
## @param key: (String) 配置中的键名。
## @param default: (Variant) 如果找不到值，则返回的默认值。
## @return: (Variant) 返回找到的值或默认值。
func get_value(section: String, key: String, default = null):
	# 调用 ConfigFile 对象的 get_value 方法来获取值。
	return _config.get_value(section, key, default)

## 设置指定节和键的值。
## @param section: (String) 要设置的节名。
## @param key: (String) 要设置的键名。
## @param value: (Variant) 要设置的新值。
func set_value(section: String, key: String, value):
	print("ConfigManager: 正在设置配置值 - 节: %s, 键: %s, 值: %s" % [section, key, value])
	# 获取设置前该键的旧值，用于发布事件。
	var old_value = get_value(section, key)
	# 调用 ConfigFile 对象的 set_value 方法来更新值。
	_config.set_value(section, key, value)
	# 调用 save_config 方法以持久化更改。
	save_config()
	# 通过事件总线发布配置变更事件。
	EventBus.publish_config_change(section, key, old_value, value)

## 获取所有动画相关的配置。
## @return: (Dictionary) 返回一个包含所有动画配置的字典。
func get_animation_configs() -> Dictionary:
	# 创建一个空字典用于存储结果。
	var anim_configs = {}
	# 获取配置文件中所有的节名。
	var sections = _config.get_sections()
	
	# 遍历所有节名。
	for section in sections:
		# 约定：所有以 "anim_" 开头的节都是动画配置。
		if section.begins_with("anim_"):
			# 如果是动画配置，获取该节下的所有键值对，并存入结果字典。
			anim_configs[section] = get_section_as_dict(section)
	
	# 返回包含所有动画配置的字典。
	return anim_configs

## 将指定节的内容作为一个字典返回。
## @param section: (String) 要获取的节名。
## @return: (Dictionary) 返回一个包含该节所有键值对的字典。
func get_section_as_dict(section: String) -> Dictionary:
	# 创建一个空字典。
	var dict = {}
	# 检查指定的节是否存在。
	if _config.has_section(section):
		# 如果存在，遍历该节下的所有键。
		for key in _config.get_section_keys(section):
			# 将键值对存入字典。
			dict[key] = get_value(section, key)
	# 返回构建好的字典。
	return dict

## 获取当前激活的AI提供商的完整配置。
## @return: (Dictionary) 返回一个包含提供商配置的字典 (api_key, model, url)。
func get_active_ai_provider_config() -> Dictionary:
	# 直接从配置中获取要使用的提供商的完整节名，例如 "AI_Zhipu"
	var section_name = get_value("AI", "active_provider", "")
	if section_name.is_empty():
		push_warning("Active AI provider is not set in config section [AI].")
		return {}
	
	# 检查该提供商的配置节是否存在
	if not _config.has_section(section_name):
		push_warning("Active AI provider section '[%s]' not found in config." % section_name)
		return {}
	
	# 将该节的内容作为字典返回
	return get_section_as_dict(section_name)

## 检查AI功能是否已在配置中启用。
## @return: (bool) 如果启用则返回 true，否则返回 false。
func is_ai_enabled() -> bool:
	# 从 "AI" 节获取 "enabled" 键的值，默认为 false
	return bool(get_value("AI", "enabled", false))


# ==================== 文件监听 ====================

## 开始监听配置文件的变化。
func start_file_monitoring():
	print("ConfigManager: 正在启动文件监控...")
	# 如果已经在监听，则直接返回。
	if _is_monitoring:
		return
	
	# 检查计时器是否尚未创建。
	if not _file_check_timer:
		# 如果未创建，则创建一个新的 Timer 实例。
		_file_check_timer = Timer.new()
		# 设置计时器每1秒触发一次。
		_file_check_timer.wait_time = 1.0
		# 将计时器的 timeout 信号连接到 _check_file_modified 方法。
		_file_check_timer.timeout.connect(_check_file_modified)
		# 将计时器作为子节点添加到场景树中。
		add_child(_file_check_timer)
	
	# 获取文件当前的最后修改时间。
	_last_modified_time = FileAccess.get_modified_time(Constants.AppPaths.CONFIG_FILE_PATH)
	
	# 启动计时器。
	_file_check_timer.start()
	# 设置监听状态为 true。
	_is_monitoring = true

## 停止监听配置文件的变化。
func stop_file_monitoring():
	print("ConfigManager: 正在停止文件监控...")
	# 如果当前未在监听，则直接返回。
	if not _is_monitoring:
		# 退出函数。
		return
	
	# 检查计时器是否存在。
	if _file_check_timer:
		# 如果存在，则停止它。
		_file_check_timer.stop()
	
	# 设置监听状态为 false。
	_is_monitoring = false
	# 打印日志信息。
	print("已停止监控配置文件。")


# ==================== 私有方法 ====================

## 验证配置文件的基本结构。
func _validate_config():
	# 检查必需的配置节是否存在。动画配置不再是必需的。
	var required_sections = ["pet", "interface", "AI"]
	var missing_sections = []
	
	for section in required_sections:
		if not _config.has_section(section):
			missing_sections.append(section)
	
	# 如果有缺失的节，添加默认配置
	if missing_sections.size() > 0:
		print("配置文件缺少节: %s，正在添加默认值。" % missing_sections)
		_add_missing_sections(missing_sections)
		save_config()

## 添加缺失的配置节。
## @param missing_sections: (Array) 缺失的配置节名称列表。
func _add_missing_sections(missing_sections: Array):
	for section in missing_sections:
		match section:
			"pet":
				for key in Constants.DefaultConfig.PET_CONFIG:
					_config.set_value("pet", key, Constants.DefaultConfig.PET_CONFIG[key])
			"interface":
				# 假设INTERFACE_CONFIG在常量中定义
				for key in Constants.DefaultConfig.INTERFACE_CONFIG:
						_config.set_value("interface", key, Constants.DefaultConfig.INTERFACE_CONFIG[key])
			"AI":
				_config.set_value("AI", "enabled", true)
				_config.set_value("AI", "active_provider", "AI_Zhipu")
				_config.set_value("AI_Zhipu", "api_key", "your_api_key_here")
				_config.set_value("AI_Zhipu", "model", "your_model")
				_config.set_value("AI_Zhipu", "url", "your_api_url")


## 检查文件是否被修改（由计时器调用）。
func _check_file_modified():
	print("ConfigManager: 正在检查文件修改... (上次修改时间: %d)" % _last_modified_time)
	# 获取文件当前的修改时间。
	var modified_time = FileAccess.get_modified_time(Constants.AppPaths.CONFIG_FILE_PATH)
	
	# 检查当前修改时间是否晚于记录的上次修改时间。
	if modified_time > _last_modified_time:
		# 如果文件已被修改，则更新记录的时间。
		_last_modified_time = modified_time
		# 创建一个新的ConfigFile实例来测试加载
		var temp_config = ConfigFile.new()
		var err = temp_config.load(Constants.AppPaths.CONFIG_FILE_PATH)
		if err != OK:
			# 如果加载失败，保持当前配置不变
			push_error("ConfigManager: Failed to reload config file (Error code: %d). Keeping previous configuration." % err)
			return
		
		# 如果加载成功，替换当前配置
		_config = temp_config
		# 验证新配置
		_validate_config()
		# 通过事件总线发布一个特殊的配置变更信号，通知所有模块配置已重载。
		EventBus.publish_config_change("__global__", "__reload__", null, null)
		# 等待一帧确保事件处理完成
		await get_tree().process_frame

## 创建一份默认的配置文件。
func _create_default_config():
	print("ConfigManager: 正在创建默认配置文件...")
	# --- 宠物配置 ---
	for key in Constants.DefaultConfig.PET_CONFIG:
		_config.set_value("pet", key, Constants.DefaultConfig.PET_CONFIG[key])
	
	# --- 界面配置 ---
	# 检查常量是否存在，避免出错
	for key in Constants.DefaultConfig.INTERFACE_CONFIG:
		_config.set_value("interface", key, Constants.DefaultConfig.INTERFACE_CONFIG[key])

	# --- AI 配置 ---
	_config.set_value("AI", "enabled", true)
	_config.set_value("AI", "active_provider", "AI_Zhipu")
	_config.set_value("AI_Zhipu", "api_key", "your_api_key_here")
	_config.set_value("AI_Zhipu", "model", "your_model")
	_config.set_value("AI_Zhipu", "url", "your_api_url")

	# --- 动画配置 ---
	var all_animation_configs = Constants.DefaultConfig.get_all_animation_configs()
	for anim_name in all_animation_configs:
		var config_data = all_animation_configs[anim_name]
		# 使用 "anim_" 前缀创建节
		var section_name = "anim_%s" % anim_name
		for key in config_data:
			_config.set_value(section_name, key, config_data[key])
