extends Node # 音效管理器

@onready var audio_placement: AudioStreamPlayer = $AudioPlacement # 放置状态音效播放器
@onready var audio_feeding: AudioStreamPlayer = $AudioFeeding # 投喂状态音效播放器
@onready var audio_petting: AudioStreamPlayer = $AudioPetting # 抚摸状态音效播放器

func play_for_state(state: String) -> void: # 根据状态播放对应音效（均使用占位 mp3）
	match state:
		"PLACEMENT":
			if audio_placement: audio_placement.play()
		"FEEDING":
			if audio_feeding: audio_feeding.play()
		"PETTING":
			if audio_petting: audio_petting.play()
