# ai_chat_window.gd
# 该脚本控制ai_chat_window.tscn场景的UI交互。
extends Window

# UI节点引用 (路径已根据新的场景结构更新)
@onready var message_display: RichTextLabel = %MessageDisplay
@onready var user_input: LineEdit = %UserInput
@onready var send_button: Button = %SendButton

# AI管理器实例 (由外部设置)
var ai_manager: AIManager

# 初始化聊天窗口
func _ready() -> void:
	# 设置窗口标题和初始大小
	title = "AI Chat"
	size = Vector2i(400, 600)

	# 连接窗口关闭按钮信号，点击关闭时隐藏窗口而非销毁
	close_requested.connect(func(): hide())

	# 连接UI信号
	send_button.pressed.connect(self._on_send_message)
	user_input.text_submitted.connect(self._on_send_message)

	# 添加欢迎消息
	message_display.append_text("[color=gray]你好！可以开始聊天了。[/color]\n")

## 设置AI管理器实例，由创建者调用
func set_ai_manager(manager_instance: AIManager):
	# 如果已经设置过，就不要重复连接信号
	if self.ai_manager:
		if self.ai_manager.is_connected("response_received", self._on_ai_response):
			self.ai_manager.response_received.disconnect(self._on_ai_response)
		if self.ai_manager.is_connected("error_occurred", self._on_ai_error):
			self.ai_manager.error_occurred.disconnect(self._on_ai_error)

	self.ai_manager = manager_instance

	# 确保ai_manager有效再连接信号
	if self.ai_manager:
		# 连接AI管理器的信号
		ai_manager.response_received.connect(self._on_ai_response)
		ai_manager.error_occurred.connect(self._on_ai_error)
	else:
		push_error("AI聊天窗口: AIManager实例为空。")


# 发送消息的逻辑
func _on_send_message(_text = "") -> void:
	var message_text = user_input.text.strip_edges()
	# 如果消息为空，则不发送
	if message_text.is_empty():
		return
	
	# 检查ai_manager是否有效
	if not ai_manager:
		_on_ai_error("AIManager尚未设置。\n")
		return

	# 在显示区域添加用户消息 (使用BBCode设置颜色)
	# 在显示区域添加用户消息 (使用BBCode设置颜色)
	message_display.append_text("[color=lightblue]You:[/color] %s\n" % message_text)
	
	# 调用AIManager发送消息
	ai_manager.send_message(message_text)
	
	# 显示等待提示
	message_display.append_text("[color=gray]AI is thinking...[/color]\n")

	# 清空输入框并将焦点重新设置到输入框
	user_input.clear()
	user_input.grab_focus()


# 接收到AI回复的逻辑
func _on_ai_response(response_text: String) -> void:
	# 移除 "AI is thinking..." 提示
	var current_text = message_display.text
	var thinking_text = "[color=gray]AI is thinking...[/color]\n"
	if current_text.ends_with(thinking_text):
		message_display.text = current_text.trim_suffix(thinking_text)

	message_display.append_text("[color=lightgreen]AI:[/color] %s\n" % response_text)

# 处理错误的逻辑
func _on_ai_error(error_message: String) -> void:
	# 移除 "AI is thinking..." 提示
	var current_text = message_display.text
	var thinking_text = "[color=gray]AI is thinking...[/color]\n"
	if current_text.ends_with(thinking_text):
		message_display.text = current_text.trim_suffix(thinking_text)

	# 在显示区域添加错误提示
	message_display.append_text("[color=red]Error:[/color] %s\n" % error_message)
