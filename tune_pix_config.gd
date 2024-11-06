@tool
class_name TunePixConfig extends Resource

signal audio_changed
signal visuals_changed

# Audio analyzer
enum FreqCurv {
	QUADRATIC,
	SIGMOID,
}
enum EvalType {
	MAX,
	AVERAGE,
}
enum EvalCurve {
	LINEAR,
	QUADRATIC,
	CUBIC,
}

# Radio
enum SpeakerPlacement {
	LEFT,
	BOTH,
	RIGHT,
}
enum SpeakerAlignment {
	TOP,
	CENTER,
	BOTTOM,
}


@export_group("Audio")
@export var stream: AudioStream:
	set(val):
		stream = val
		audio_changed.emit()
@export var bpm: float = 60.0
@export var bus_index := 0:
	set(val):
		bus_index = val
		audio_changed.emit()
@export var spectrum_analyzer_effect_index := 0:
	set(val):
		spectrum_analyzer_effect_index = val
		audio_changed.emit()

@export_subgroup("Analyzer")
@export_range(1, 12, 1) var segments := 4:
	set(val):
		segments = val
		visuals_changed.emit()
@export var freq_min := 32.0:
	set(val):
		freq_min = val
		visuals_changed.emit()
@export var freq_max := 8000.0:
	set(val):
		freq_max = val
		visuals_changed.emit()
@export var freq_curve: FreqCurv = FreqCurv.QUADRATIC:
	set(val):
		freq_curve = val
		visuals_changed.emit()
@export_range(-120.0, 0.0, 0.1) var min_db := -60.0:
	set(val):
		min_db = val
		visuals_changed.emit()
@export_range(-120.0, 0.0, 0.1) var max_db := -20.0:
	set(val):
		max_db = val
		visuals_changed.emit()
@export_range(0.0, 10.0, 0.01) var decay_speed := 1.0:
	set(val):
		decay_speed = val
		visuals_changed.emit()
@export_range(0.0, 10.0, 0.01) var grow_speed := 2.0:
	set(val):
		grow_speed = val
		visuals_changed.emit()
@export var eval_type: EvalType = EvalType.MAX:
	set(val):
		eval_type = val
		visuals_changed.emit()
@export var eval_curve: EvalCurve = EvalCurve.LINEAR:
	set(val):
		eval_curve = val
		visuals_changed.emit()


@export_group("Visuals")
@export var fps := 24

@export_subgroup("Art", "art_")
@export var art_texture: Texture2D:
	set(val):
		art_texture = val
		visuals_changed.emit()
@export var art_outline := true:
	set(val):
		art_outline = val
		visuals_changed.emit()
@export_range(0, 16, 1) var art_outline_size = 2:
	set(val):
		art_outline_size = val
		visuals_changed.emit()
@export var art_outline_color := Color.GRAY:
	set(val):
		art_outline_color = val
		visuals_changed.emit()
@export_range(0, 32, 1) var art_padding := 8:
	set(val):
		art_padding = val
		visuals_changed.emit()

@export_subgroup("Box", "box_")
@export var box_color: Color = Color.WHITE:
	set(val):
		box_color = val
		visuals_changed.emit()
@export_range(0, 32, 1) var box_border_radius := 8:
	set(val):
		box_border_radius = val
		visuals_changed.emit()
@export_range(0, 32, 1) var box_gap := 8:
	set(val):
		box_gap = val
		visuals_changed.emit()

@export_subgroup("Speaker", "speaker_")
@export var speaker_placement: SpeakerPlacement = SpeakerPlacement.RIGHT:
	set(val):
		speaker_placement = val
		visuals_changed.emit()
@export var speaker_alignment: SpeakerAlignment = SpeakerAlignment.CENTER:
	set(val):
		speaker_alignment = val
		visuals_changed.emit()
@export var speaker_color: Color = Color.BLACK:
	set(val):
		speaker_color = val
		visuals_changed.emit()
@export var speaker_outline := false:
	set(val):
		speaker_outline = val
		visuals_changed.emit()
@export_range(0, 16, 1) var speaker_outline_size = 2:
	set(val):
		speaker_outline_size = val
		visuals_changed.emit()
@export var speaker_outline_color: Color = Color.GRAY:
	set(val):
		speaker_outline_color = val
		visuals_changed.emit()
@export_range(1, 64, 1) var speaker_radius := 24:
	set(val):
		speaker_radius = val
		visuals_changed.emit()
@export_range(1, 64, 1) var speaker_bump_radius := 16:
	set(val):
		speaker_bump_radius = val
		visuals_changed.emit()
@export_range(0, 8, 1) var speaker_partitions := 4:
	set(val):
		speaker_partitions = val
		visuals_changed.emit()
@export_range(0, 32, 1) var speaker_padding := 8:
	set(val):
		speaker_padding = val
		visuals_changed.emit()

@export_subgroup("Antenna", "antenna_")
@export var antenna_visible := true:
	set(val):
		antenna_visible = val
		visuals_changed.emit()
@export var antenna_color: Color = Color.WHITE:
	set(val):
		antenna_color = val
		visuals_changed.emit()
@export_range(0, 256, 1) var antenna_length = 64:
	set(val):
		antenna_length = val
		visuals_changed.emit()
@export_range(0, 16, 1) var antenna_width = 4:
	set(val):
		antenna_width = val
		visuals_changed.emit()
@export_range(0, 32, 1) var antenna_receiver_radius = 2:
	set(val):
		antenna_receiver_radius = val
		visuals_changed.emit()
@export var antenna_receiver_color: Color = Color.WHITE:
	set(val):
		antenna_receiver_color = val
		visuals_changed.emit()
@export_range(0, 90, 1) var antenna_angle = 30:
	set(val):
		antenna_angle = val
		visuals_changed.emit()
