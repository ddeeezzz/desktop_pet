# scripts/core/base_manager.gd
# 一个提供标准化初始化流程的基类，所有Manager和Controller都应继承自此类。
class_name BaseManager
extends Node

## 当此模块的初始化逻辑执行完毕后发出。
signal initialization_completed

## 一个布尔标志，用于防止重复初始化。
var _is_initialized: bool = false

## 公共的初始化入口方法。
func initialize():
	# 检查是否尚未初始化，防止重复调用。
	if not _is_initialized:
		# 调用真正执行初始化逻辑的私有方法。
		_do_initialize()
		# 将状态标记为已初始化。
		_is_initialized = true
		# 发出初始化完成信号，通知其他等待的模块。
		# 使用 call_deferred 来确保 await 有时间先建立监听。
		initialization_completed.emit.call_deferred()

## 子类需要重写此方法，以实现其特定的初始化逻辑。
func _do_initialize():
	# 这是一个虚拟方法，需要子类来实现。
	# 使用 push_warning 提醒开发者如果忘记实现。
	push_warning("BaseManager._do_initialize()应该由子类重写。")
	pass

## 提供一个公共方法，用于查询此模块是否已完成初始化。
## @return: (bool) 如果已初始化则返回 true。
func is_ready() -> bool:
	# 返回初始化状态。
	return _is_initialized
