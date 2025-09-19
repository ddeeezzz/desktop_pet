# ai_manager.gd
# 该脚本负责管理与AI API的交互，包括发送请求和处理响应。
extends BaseManager
class_name AIManager

# AI响应成功接收的信号
signal response_received(response_text)
# 发生错误的信号
signal error_occurred(error_message)

# 节点引用
@onready var config_manager: ConfigManager = %ConfigManager

# HTTP请求节点
var http_request: HTTPRequest


# ==================== Godot 生命周期方法 ====================

## 重写 BaseManager 的 _do_initialize 方法。
func _do_initialize():
	print("AIManager: 开始初始化...")
	# 创建一个新的HTTPRequest节点并添加到场景树中
	http_request = HTTPRequest.new()
	add_child(http_request)
	# 连接请求完成的信号
	http_request.request_completed.connect(self._on_request_completed)
	print("AIManager: 初始化完成。")

# ==================== 公共方法 ====================

# 发送消息到AI API
## 发送消息到AI API
func send_message(user_message: String) -> void:
	print("AIManager: 正在发送消息: %s" % user_message)
	# 检查ConfigManager是否存在
	if not config_manager:
		push_error("AIManager: ConfigManager node not found!")
		error_occurred.emit("配置管理器未找到。")
		return

	# 检查AI功能是否启用
	if not config_manager.is_ai_enabled():
		error_occurred.emit("AI功能未启用。")
		return

	# 获取当前AI提供商的配置
	var provider_config = config_manager.get_active_ai_provider_config()
	if provider_config.is_empty():
		error_occurred.emit("无法获取有效的AI提供商配置。")
		return

	var api_key = provider_config.get("api_key", "")
	var model = provider_config.get("model", "")
	var url = provider_config.get("url", "")

	if api_key.is_empty() or api_key == "your_api_key_here":
		error_occurred.emit("无效的API Key，请在配置文件中设置。")
		return

	# 构建请求头
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer %s" % api_key
	]

	# 构建请求体
	var body = {
		"model": model,
		"messages": [
			{
				"role": "user",
				"content": user_message
			}
		]
	}
	
	# 将请求体字典转换为JSON字符串
	var body_json = JSON.stringify(body)

	# 发起HTTP POST请求
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body_json)
	if error != OK:
		error_occurred.emit("创建HTTP请求失败，错误码: %d" % error)


# ==================== 信号处理 ====================

# 当HTTP请求完成时调用
## 当HTTP请求完成时调用
func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print("AIManager: HTTP请求完成，结果: %d, 响应码: %d" % [result, response_code])
	# 检查请求结果
	if result != HTTPRequest.RESULT_SUCCESS:
		error_occurred.emit("请求失败，结果: %d" % result)
		return

	# 解析响应体
	var response_text = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)

	# 检查HTTP状态码和JSON解析结果
	if response_code >= 400 or json == null:
		var error_msg = "HTTP错误，状态码: %d" % response_code
		if json and json.has("error"):
			error_msg += " - %s" % json.error.message
		error_occurred.emit(error_msg)
		return

	# 检查响应内容
	if not json.has("choices") or json.choices.size() == 0 or not json.choices[0].has("message") or not json.choices[0].message.has("content"):
		error_occurred.emit("收到了无效的响应数据格式。")
		return
	
	# 提取并发送AI的回复
	var ai_response = json.choices[0].message.content
	response_received.emit(ai_response)
