extends Resource
class_name AudioItem


@export_range(0.0, 1.0, 0.05) var volume:float = 1.0
@export_range(0.01, 1.0, 0.05) var pitch_variation:float = 1.0
@export_range(0.0, 1.0, 0.05) var pitch_random:float = 0.0
@export var random_file:bool = true
@export var audio_files: Array[AudioStream]

@export var name:String = ""
