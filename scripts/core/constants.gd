# scripts/core/constants.gd
# 该文件定义了整个应用程序中使用的核心常量。

# ==================== 应用信息 ====================
## 应用信息类，用于存储版本号等静态信息。
class AppInfo:
	## 应用版本号
	const VERSION: String = "1.0.0"
	## 应用名称
	const APP_NAME: String = "Desktop Pet"


# ==================== 文件与路径 ====================
## 文件和路径常量类，用于管理所有文件系统相关的路径。
class AppPaths:
	## 用户数据目录路径
	const USER_DIR: String = "user://"
	## 配置文件名
	const CONFIG_FILE_NAME: String = "settings.cfg"
	## 完整配置文件路径
	const CONFIG_FILE_PATH: String = USER_DIR + CONFIG_FILE_NAME
	## 日志文件名
	const LOG_FILE_NAME: String = "app.log"
	## 完整日志文件路径
	const LOG_FILE_PATH: String = USER_DIR + LOG_FILE_NAME


# ==================== 动画相关常量 ====================
## 动画相关常量类，定义了动画处理的边界和默认值。
class AppAnimation:
	## 默认动画帧率
	const DEFAULT_FPS: float = 8.0
	## 最小帧率
	const MIN_FPS: float = 0.1
	## 最大帧率
	const MAX_FPS: float = 60.0
	## 默认帧时长
	const DEFAULT_FRAME_DURATION: float = 1.0
	## 最大帧数限制
	const MAX_FRAME_COUNT: int = 1000 # 增加限制以支持更复杂的动画


# ==================== UI 相关常量 ====================
## UI相关的常量类，定义了界面元素的默认行为和限制。
class AppUI:
	## 默认主题路径
	const DEFAULT_THEME_PATH: String = "res://assets/themes/default_theme.tres"
	## 默认缩放级别
	const DEFAULT_SCALE: float = 1.0
	## 最小缩放级别
	const MIN_SCALE: float = 0.1
	## 最大缩放级别
	const MAX_SCALE: float = 5.0
	## 默认窗口不透明度
	const DEFAULT_MODULATE: float = 1.0
	
	# 尺寸相关常量
	## 宠物基础大小
	const PET_BASE_SIZE: Vector2 = Vector2(256, 256)
	## PetArea基础大小
	const PET_AREA_BASE_SIZE: Vector2 = Vector2(128, 128)
	## PetArea缩放倍数
	const PET_AREA_SCALE: float = 2.0
	## 菜单估计大小
	const MENU_SIZE: Vector2 = Vector2(60, 180)


# ==================== 错误与日志等级 ====================
## 错误和日志等级常量类。
class LogLevel:
	## 信息级别
	const INFO: String = "info"
	## 警告级别
	const WARNING: String = "warning"
	## 错误级别
	const ERROR: String = "error"
	## 严重错误级别
	const CRITICAL: String = "critical"


# ==================== 宠物状态 ====================
## 宠物状态常量类，用于定义状态机的各种状态。
class PetState:
	## 闲置状态
	const IDLE: String = "idle"
	## 拖动状态
	const DRAGGING: String = "dragging"
	## 交互状态（例如抚摸）
	const INTERACTING: String = "interacting"
	## 隐藏状态
	const HIDDEN: String = "hidden"


# ==================== 默认配置数据 ====================
## 默认配置数据常量类，包含所有默认的配置值。
class DefaultConfig:
	# 动画循环设置
	## 默认循环的动画名称（使用完整的带前缀名称）
	const LOOPING_ANIMATIONS: Array[String] = ["anim_cloud", "anim_initial", "anim_placement"]
	
	# 宠物配置
	## 宠物默认配置字典
	const PET_CONFIG: Dictionary = {
		"scale": AppUI.DEFAULT_SCALE
	}
	
	# 界面配置
	## 界面默认配置字典
	const INTERFACE_CONFIG: Dictionary = {
		"theme": "default"
	}
	
	# 动画配置
	## initial动画默认配置
	const INITIAL_ANIMATION_CONFIG: Dictionary = {
		"texture": "res://assets/animations/init.png",
		"hframes": 3,
		"vframes": 2,
		"frames": 5,
		"fps": AppAnimation.DEFAULT_FPS,
		"frame_durations": '{"0": 2.0, "1": 1.0, "2": 2.0, "3": 1.0, "4": 10.0}'
	}
	
	## placement动画默认配置
	const PLACEMENT_ANIMATION_CONFIG: Dictionary = {
		"texture": "res://assets/animations/placement.png",
		"hframes": 3,
		"vframes": 2,
		"frames": 6,
		"fps": 15.0,
		"frame_durations": '{"0": 2.0, "1": 1.0, "2": 2.0, "3": 1.0, "4": 5.0, "5": 20.0}'
	}
	
	## feeding动画默认配置
	const FEEDING_ANIMATION_CONFIG: Dictionary = {
		"texture": "res://assets/animations/feeding.png",
		"hframes": 4,
		"vframes": 4,
		"frames": 16,
		"fps": 6.0,
		"frame_durations": '{}'
	}
	
	## petting动画默认配置
	const PETTING_ANIMATION_CONFIG: Dictionary = {
		"texture": "res://assets/animations/petting.png",
		"hframes": 7,
		"vframes": 7,
		"frames": 46,
		"fps": 30.0,
		"frame_durations": '{"0": 5.67, "1": 6.67, "2": 1.0, "3": 5.67, "4": 1.0, "5": 7.67, "6": 7.67, "7": 7.67, "8": 7.67, "9": 1.0, "10": 6.67, "11": 7.67, "12": 2.33, "13": 5.67, "14": 7.67, "15": 3.33, "16": 4.33, "17": 7.67, "18": 6.67, "19": 1.0, "20": 7.67, "21": 5.67, "22": 2.33, "23": 7.67, "24": 2.33, "25": 4.33, "26": 1.0, "27": 7.67, "28": 7.67, "29": 7.67, "30": 7.67, "31": 1.0, "32": 6.67, "33": 7.67, "34": 2.33, "35": 5.67, "36": 7.67, "37": 3.33, "38": 4.33, "39": 7.67, "40": 4.33, "41": 3.33, "42": 7.67, "43": 5.67, "44": 3.33, "45": 16.67}'
	}
	
	## cloud动画默认配置
	const CLOUD_ANIMATION_CONFIG: Dictionary = {
		"texture": "res://assets/animations/cloud.png",
		"hframes": 3,
		"vframes": 1,
		"frames": 3,
		"fps": 5.0,
		"frame_durations": '{"0": 1.0, "1": 1.0, "2": 5.0}'
	}
	
	## 获取所有动画配置的字典
	static func get_all_animation_configs() -> Dictionary:
		return {
			"initial": INITIAL_ANIMATION_CONFIG,
			"placement": PLACEMENT_ANIMATION_CONFIG,
			"feeding": FEEDING_ANIMATION_CONFIG,
			"petting": PETTING_ANIMATION_CONFIG,
			"cloud": CLOUD_ANIMATION_CONFIG
		}
