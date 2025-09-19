# scripts/components/file_selector.gd
# 一个文件选择器组件，封装了 FileDialog 节点的功能，并通过事件总线进行通信。

# ==================== 文件选择器组件 ====================
## @class_name FileSelector
## 继承自 FileDialog，使其拥有文件对话框的所有功能。
extends FileDialog
class_name FileSelector

# -------------------- 私有变量 --------------------
## 用于存储与此次文件选择操作相关的上下文信息，例如正在更改哪个动画。
var _context: Dictionary = {}


# ==================== Godot 生命周期方法 ====================

## _ready() 方法，在节点准备好时被调用一次。
func _ready():
	# 将自身的 file_selected 信号连接到 _on_file_selected 方法。
	# 当用户在对话框中选择一个文件并点击“确定”时，该信号会被发出。
	self.file_selected.connect(_on_file_selected)


# ==================== 公共方法 ====================

## 打开文件选择对话框。
## @param context: (Dictionary) 传入的上下文信息，用于后续处理。
func open_dialog(context: Dictionary = {}):
	# 将传入的上下文信息存储到私有变量 _context 中。
	_context = context
	# 调用 FileDialog 的 popup_centered 方法，弹出并居中显示文件对话框。
	self.popup_centered()


# ==================== 信号处理 ====================

## 当 file_selected 信号被发出时调用的私有方法。
## @param path: (String) 用户所选择的文件的完整路径。
func _on_file_selected(path: String):
	# 创建一个新的字典，用于将路径和上下文信息一起通过事件总线发布出去。
	var payload = {
		# 存储文件路径。
		"path": path,
		# 存储上下文信息。
		"context": _context
	}
	# 通过事件总线发出 file_selected 信号，并携带 payload 作为参数。
	EventBus.file_selected.emit(payload)
	# 重置上下文变量，为下一次操作做准备。
	_context = {}
