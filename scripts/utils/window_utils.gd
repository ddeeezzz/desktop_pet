# scripts/utils/window_utils.gd
# 提供一系列与窗口操作相关的静态辅助方法。

# ==================== 窗口工具 ====================
## @class_name WindowUtils
## 一个包含静态窗口操作方法的工具类。
class_name WindowUtils

# -------------------- 公共静态方法 --------------------

## 设置窗口的基本属性，使其适合桌面宠物。
## @param window: (Window) 需要被设置的目标窗口节点。
static func setup_desktop_pet_window(window: Window):
	# 检查传入的 window 对象是否有效。
	if not window:
		# 如果无效，打印错误信息并返回。
		push_error("WindowUtils: 传入的窗口对象无效。")
		# 提前退出函数。
		return
	
	# 设置窗口模式为普通窗口化。
	window.mode = Window.MODE_WINDOWED
	# 设置窗口背景为透明。
	window.transparent_bg = true
	# 设置窗口总是在最前端显示。
	window.always_on_top = true
	# 设置窗口为无边框模式。
	window.borderless = true

## 智能地计算并设置一个窗口相对于另一个窗口的位置。
## @param window_to_place: (Window) 需要被定位的窗口。
## @param main_window: (Window) 作为参考系的父窗口或主窗口。
## @param margin: (int) 两个窗口之间的像素间距。
static func position_window_next_to(window_to_place: Window, main_window: Window, margin: int = 20):
	# 检查传入的窗口对象是否都有效。
	if not window_to_place or not main_window:
		# 如果有任何一个无效，则打印错误并返回。
		push_error("WindowUtils: 传入的窗口对象无效。")
		# 提前退出函数。
		return

	# 获取主显示器的尺寸。
	var screen_size = DisplayServer.screen_get_size()
	# 获取主窗口的位置。
	var main_window_pos = main_window.position
	# 获取主窗口的尺寸。
	var main_window_size = main_window.size
	
	# 判断主窗口是否在屏幕的右半边。
	var is_main_window_on_right = main_window_pos.x > (screen_size.x / 2)
	
	# 声明一个变量用于存储计算出的新位置。
	var new_pos: Vector2i
	
	# 如果主窗口在右边。
	if is_main_window_on_right:
		# 将目标窗口放在主窗口的左边。
		new_pos = Vector2i(
			# X坐标 = 主窗口X位置 - 目标窗口宽度 - 间距
			main_window_pos.x - window_to_place.size.x - margin,
			# Y坐标 = 与主窗口垂直居中对齐
			main_window_pos.y + (main_window_size.y - window_to_place.size.y) / 2
		)
	# 如果主窗口在左边。
	else:
		# 将目标窗口放在主窗口的右边。
		new_pos = Vector2i(
			# X坐标 = 主窗口X位置 + 主窗口宽度 + 间距
			main_window_pos.x + main_window_size.x + margin,
			# Y坐标 = 与主窗口垂直居中对齐
			main_window_pos.y + (main_window_size.y - window_to_place.size.y) / 2
		)
	
	# 使用 clamp 函数确保窗口不会超出屏幕边界。
	new_pos.x = clamp(new_pos.x, 0, screen_size.x - window_to_place.size.x)
	# 同样确保Y坐标不越界。
	new_pos.y = clamp(new_pos.y, 0, screen_size.y - window_to_place.size.y)
	
	# 将计算出的最终位置应用到目标窗口。
	window_to_place.position = new_pos

# -------------------- 鼠标穿透相关方法 --------------------

## 设置窗口的鼠标穿透功能
## @param window: (Window) 目标窗口
## @param enabled: (bool) 是否启用穿透
static func setup_mouse_passthrough(window: Window, enabled: bool):
	if not window:
		push_error("WindowUtils: 传入的窗口对象无效。")
		return
	
	if enabled:
		# 启用穿透时传入空数组，表示整个窗口都穿透
		DisplayServer.window_set_mouse_passthrough(PackedVector2Array())
	else:
		# 禁用穿透
		DisplayServer.window_set_mouse_passthrough(PackedVector2Array())

## 将Node2D节点的本地矩形转换为窗口坐标
## @param node: (Node2D) 目标节点
## @param local_rect: (Rect2) 节点本地坐标系下的矩形
## @return PackedVector2Array: 窗口坐标下的四边形顶点
static func node_rect_to_window_coords(node: Node2D, local_rect: Rect2) -> PackedVector2Array:
	if not node:
		push_error("WindowUtils: 传入的节点对象无效。")
		return PackedVector2Array()
	
	# 获取节点的全局变换
	var global_transform = node.global_transform
	
	# 计算矩形的四个角点（本地坐标）
	var corners = PackedVector2Array([
		local_rect.position,  # 左上
		Vector2(local_rect.end.x, local_rect.position.y),  # 右上
		local_rect.end,  # 右下
		Vector2(local_rect.position.x, local_rect.end.y)   # 左下
	])
	
	# 转换为全局坐标，然后转换为窗口坐标
	var window_coords = PackedVector2Array()
	for corner in corners:
		var global_pos = global_transform * corner
		# 全局坐标就是窗口坐标（因为窗口就是全局坐标系）
		window_coords.append(global_pos)
	
	return window_coords

## 将Control节点的矩形转换为窗口坐标
## @param control: (Control) 目标控件
## @param local_rect: (Rect2) 控件本地坐标系下的矩形
## @return PackedVector2Array: 窗口坐标下的四边形顶点
static func control_rect_to_window_coords(control: Control, local_rect: Rect2) -> PackedVector2Array:
	if not control:
		push_error("WindowUtils: 传入的控件对象无效。")
		return PackedVector2Array()
	
	# 获取控件的全局位置
	var global_pos = control.global_position
	
	# 计算矩形的四个角点（全局坐标）
	var corners = PackedVector2Array([
		global_pos + local_rect.position,  # 左上
		global_pos + Vector2(local_rect.end.x, local_rect.position.y),  # 右上  
		global_pos + local_rect.end,  # 右下
		global_pos + Vector2(local_rect.position.x, local_rect.end.y)   # 左下
	])
	
	return corners

## 计算节点的边界矩形（全局坐标）
## @param node: (Node2D) 目标节点
## @return Rect2: 全局坐标下的边界矩形
static func get_node_global_bounds(node: Node2D) -> Rect2:
	if not node:
		push_error("WindowUtils: 传入的节点对象无效。")
		return Rect2()
	
	# TODO: 根据节点类型实现不同的边界计算逻辑
	# 目前返回基于position的简单矩形
	var pos = node.global_position
	return Rect2(pos - Vector2(50, 50), Vector2(100, 100))

## 合并多个重叠的矩形
## @param rects: (Array[Rect2]) 要合并的矩形数组
## @return Array[Rect2]: 合并后的矩形数组
static func merge_overlapping_rects(rects: Array[Rect2]) -> Array[Rect2]:
	if rects.size() <= 1:
		return rects
	
	var merged = []
	var sorted_rects = rects.duplicate()
	
	# 简单实现：返回包围所有矩形的最小矩形
	# TODO: 实现更复杂的重叠检测和合并算法
	var union_rect = sorted_rects[0]
	for i in range(1, sorted_rects.size()):
		union_rect = union_rect.merge(sorted_rects[i])
	
	merged.append(union_rect)
	return merged

## 检查两个矩形是否重叠
## @param rect1: (Rect2) 第一个矩形
## @param rect2: (Rect2) 第二个矩形
## @return bool: 是否重叠
static func rects_overlap(rect1: Rect2, rect2: Rect2) -> bool:
	return rect1.intersects(rect2)

## 调试：打印窗口坐标数组
## @param coords: (PackedVector2Array) 坐标数组
## @param label: (String) 标签
static func debug_print_coords(coords: PackedVector2Array, label: String = "坐标"):
	print("WindowUtils调试 - %s：" % label)
	for i in range(coords.size()):
		print("  点%d: (%.1f, %.1f)" % [i, coords[i].x, coords[i].y])
