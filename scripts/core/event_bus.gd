# scripts/core/event_bus.gd
# 全局事件总线，作为一个自动加载的单例，用于在不同模块之间解耦通信。

# ==================== 事件总线 ====================
# 继承自 Node，使其能够成为场景树的一部分并使用信号机制。
extends Node

# -------------------- 状态变更信号 --------------------
## 当宠物或应用状态发生改变时发出。
## @param old_state: (String) 变化前的旧状态。
## @param new_state: (String) 变化后的新状态。
@warning_ignore("unused_signal")
signal state_changed(old_state: String, new_state: String)

# -------------------- 配置变更信号 --------------------
## 当任何配置项被修改时发出。
## @param section: (String) 被修改的配置所在的节 (section)。
## @param key: (String) 被修改的配置项的键 (key)。
## @param old_value: (Variant) 配置项的旧值。
## @param new_value: (Variant) 配置项的新值。
@warning_ignore("unused_signal")
signal config_changed(section: String, key: String, old_value, new_value)

# -------------------- 动画相关信号 --------------------
## 当动画重新加载时发出。
@warning_ignore("unused_signal")
signal animations_reloaded

## 请求播放特定动画时发出。
## @param anim_name: (String) 请求播放的动画名称。
@warning_ignore("unused_signal")
signal animation_play_requested(anim_name: String)

# -------------------- UI 相关信号 --------------------
## 当UI主题需要更新时发出。
## @param theme_path: (String) 新主题资源的路径。
@warning_ignore("unused_signal")
signal theme_changed(theme_path: String)

## 当宠物缩放比例改变时发出。
## @param new_scale: (float) 新的缩放比例值。
@warning_ignore("unused_signal")
signal scale_changed(new_scale: float)

## 请求切换设置面板中的页面时发出。
## @param panel_name: (String) 要切换到的面板名称。
@warning_ignore("unused_signal")
signal panel_switch_requested(panel_name: String)

# -------------------- 文件操作信号 --------------------
## 当用户选择了一个文件后发出。
## @param file_path: (String) 被选文件的完整路径。
@warning_ignore("unused_signal")
signal file_selected(file_path: String)

# -------------------- 通知与错误信号 --------------------
## 当需要向用户显示一条通知时发出。
## @param title: (String) 通知窗口的标题。
## @param message: (String) 通知的内容。
## @param type: (String) 通知的类型 (如 'info', 'warning', 'error')。
@warning_ignore("unused_signal")
signal notification_requested(title: String, message: String, type: String)

## 当应用发生可捕获的错误时发出。
## @param level: (String) 错误的严重级别 (使用 LogLevel 常量)。
## @param message: (String) 错误的描述信息。
## @param context: (Dictionary) 发生错误时的上下文信息，用于调试。
@warning_ignore("unused_signal")
signal error_occurred(level: String, message: String, context: Dictionary)

# -------------------- 输入管理相关信号 --------------------
## 当输入状态发生改变时发出。
## @param old_state: (int) 变化前的旧状态（InputManager.InputState枚举值）。
## @param new_state: (int) 变化后的新状态（InputManager.InputState枚举值）。
## @param reason: (String) 状态变更的原因，用于调试。
@warning_ignore("unused_signal")
signal input_state_changed(old_state: int, new_state: int, reason: String)


# -------------------- 应用生命周期信号 --------------------
## 当请求退出应用时发出。
@warning_ignore("unused_signal")
signal quit_requested


# ==================== 便利方法 ====================

## 发布状态变化事件的便利方法。
## @param old_state: (String) 旧状态。
## @param new_state: (String) 新状态。
func publish_state_change(old_state: String, new_state: String):
	# 发出 state_changed 信号，并携带新旧状态作为参数。
	state_changed.emit(old_state, new_state)

## 发布配置变化事件的便利方法。
## @param section: (String) 配置节。
## @param key: (String) 配置键。
## @param old_value: (Variant) 旧值。
## @param new_value: (Variant) 新值。
func publish_config_change(section: String, key: String, old_value, new_value):
	# 发出 config_changed 信号，并携带相关参数。
	config_changed.emit(section, key, old_value, new_value)

## 发布错误事件的便利方法。
## @param level: (String) 错误级别。
## @param message: (String) 错误消息。
## @param context: (Dictionary) 上下文信息，默认为空字典。
func publish_error(level: String, message: String, context: Dictionary = {}):
	# 发出 error_occurred 信号，并携带相关参数。
	error_occurred.emit(level, message, context)

## 发布通知事件的便利方法。
## @param title: (String) 标题。
## @param message: (String) 消息。
## @param type: (String) 类型，默认为 'info'。
func publish_notification(title: String, message: String, type: String = "info"):
	# 发出 notification_requested 信号，并携带相关参数。
	notification_requested.emit(title, message, type)
