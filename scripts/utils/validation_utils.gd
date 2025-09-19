# scripts/utils/validation_utils.gd
# 提供一系列静态方法，用于数据验证。

# ==================== 验证工具 ====================
## @class_name ValidationUtils
## 一个包含静态验证方法的工具类。
class_name ValidationUtils

# -------------------- 公共静态方法 --------------------

## 检查一个字典是否包含所有指定的键。
## @param dict: (Dictionary) 需要被检查的字典。
## @param required_keys: (Array) 一个包含所有必需键名的数组。
## @return: (bool) 如果所有键都存在则返回 true，否则返回 false。
static func has_required_keys(dict: Dictionary, required_keys: Array) -> bool:
	# 遍历必需键数组中的每一个键。
	for key in required_keys:
		# 检查字典中是否不包含当前键。
		if not dict.has(key):
			# 如果有任何一个键不存在，立即返回 false。
			return false
	# 如果循环完成，说明所有必需的键都存在，返回 true。
	return true

## 验证一个值是否在指定的最小值和最大值之间（包含边界）。
## @param value: (float) 需要被验证的值。
## @param min_value: (float) 允许的最小值。
## @param max_value: (float) 允许的最大值。
## @return: (bool) 如果值在范围内则返回 true，否则返回 false。
static func is_within_range(value: float, min_value: float, max_value: float) -> bool:
	# 返回一个布尔表达式的结果，该表达式检查 value 是否同时大于等于 min_value 和小于等于 max_value。
	return value >= min_value and value <= max_value

## 检查一个文件路径是否存在于文件系统中。
## @param path: (String) 需要被检查的文件路径。
## @return: (bool) 如果文件存在则返回 true，否则返回 false。
static func file_path_exists(path: String) -> bool:
	# 使用 FileAccess.file_exists() 静态方法来检查文件是否存在。
	return FileAccess.file_exists(path)

## 检查给定的对象是否实现了特定的类或脚本。
## @param object: (Object) 需要被检查的对象。
## @param class_or_script: (Variant) 要检查的类名 (String) 或脚本资源 (Script)。
## @return: (bool) 如果对象是指定类或脚本的实例，则返回 true。
static func implements_class(object: Object, class_or_script: Variant) -> bool:
	if object == null:
		return false

	# 如果传入的是字符串（类名）
	if typeof(class_or_script) == TYPE_STRING:
		return object.is_class(class_or_script)

	# 如果传入的是脚本资源
	if class_or_script is Script:
		return object.get_script() == class_or_script \
			or object.get_script().is_valid() and object.get_script().inherits_script(class_or_script)

	return false
