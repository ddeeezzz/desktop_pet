# scripts/managers/theme_manager.gd
# 主题管理器，一个自动加载的单例，负责处理UI主题的加载、应用和缓存。

# ==================== 主题管理器 ====================
## @class_name ThemeManager
## 继承自 BaseManager，使其拥有标准化的初始化流程。
extends BaseManager
class_name ThemeManager

# -------------------- 私有变量 --------------------
## 一个字典，用于缓存加载后的主题资源，以主题名称为键，Theme 资源为值。
var _theme_cache: Dictionary = {}
## 存储当前活动的主题名称。
var _current_theme_name: String = ""

# ==================== Godot 生命周期方法 ====================

## 重写 BaseManager 的 _do_initialize 方法。
func _do_initialize():
	print("ThemeManager: 开始初始化...")
	# 检查引用是否有效。
	if not ConfigManager:
		# 如果无效，报告严重错误。
		push_error("ThemeManager: ConfigManager not found!")
		# 提前退出。
		return

	# 调用 _load_all_themes 方法，加载所有定义的主题。
	_load_all_themes()
	# 从配置中获取当前应该应用的主题名称。
	var current_theme = %ConfigManager.get_value("interface", "theme", "default")
	# 调用 apply_theme 方法来应用该主题。
	apply_theme(current_theme)

	# 将 EventBus 的 config_changed 信号连接到 _on_config_changed 方法。
	EventBus.config_changed.connect(_on_config_changed)
	print("ThemeManager: 初始化完成。")


# ==================== 公共方法 ====================

## 应用一个指定名称的主题。
## @param theme_name: (String) 要应用的主题的名称（例如 "default", "dark"）。
func apply_theme(theme_name: String):
	print("ThemeManager: 正在应用主题: %s" % theme_name)
	# 检查请求的主题是否存在于缓存中。
	if _theme_cache.has(theme_name):
		# 如果存在，获取该主题资源。
		var theme = _theme_cache[theme_name]
		# 使用 get_tree().root.theme 来设置整个应用的全局主题。
		get_tree().root.theme = theme
		# 更新当前主题名称的记录。
		_current_theme_name = theme_name
		# 打印日志信息。
		print("主题已应用: %s" % theme_name)
	# 如果主题不存在于缓存中。
	else:
		# 打印错误信息。
		push_error("Theme '%s' not found in cache." % theme_name)

## 获取当前正在使用的主题的名称。
## @return: (String) 返回当前主题的名称。
func get_current_theme_name() -> String:
	# 返回存储的当前主题名称。
	return _current_theme_name

## 获取一个已加载的主题资源。
## @param theme_name: (String) 想要获取的主题的名称。
## @return: (Theme) 返回主题资源，如果不存在则返回 null。
func get_theme(theme_name: String) -> Theme:
	# 返回缓存中对应的主题资源，如果键不存在，.get() 方法会返回 null。
	return _theme_cache.get(theme_name)


# ==================== 私有方法 ====================

## 加载所有在代码中定义的主题到缓存中。
func _load_all_themes():
	print("ThemeManager: 正在加载所有主题...")
	# 定义一个字典，包含主题名称到其资源路径的映射。
	var theme_paths = {
		"default": "res://assets/themes/default_theme.tres"
	}

	# 遍历 theme_paths 字典中的每一个主题名称。
	for theme_name in theme_paths:
		# 获取对应的资源路径。
		var path = theme_paths[theme_name]
		# 检查主题文件是否存在。
		if ValidationUtils.file_path_exists(path):
			# 如果存在，加载该主题资源并将其存入缓存。
			_theme_cache[theme_name] = load(path)
		# 如果文件不存在。
		else:
			# 打印警告信息。
			print("警告: 在路径中未找到主题文件: %s" % path)


# ==================== 信号处理 ====================

## 当配置文件发生变化时调用。
## @param section: (String) 变化的配置所在的节。
## @param key: (String) 变化的配置的键。
## @param old_value: (Variant) 旧值。
## @param new_value: (Variant) 新值。
func _on_config_changed(section: String, key: String, _old_value, new_value):
	print("ThemeManager: 收到配置变更信号。节: %s, 键: %s" % [section, key])
	# 检查变化的配置是否是界面主题。
	if section == "interface" and key == "theme":
		# 如果是，则应用新的主题值。
		apply_theme(new_value)
