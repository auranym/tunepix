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
enum AntennaPlacement {
	LEFT,
	RIGHT,
}


@export_group("Audio")
## The audio file being visualized. This will be automatically
## played when the project is run.
@export var stream: AudioStream:
	set(val):
		stream = val
		audio_changed.emit()
## Beats per minute (BPM) of the audio file. This is used
## for the antenna beat bump.
## [br][br]
## Currently, there is not support for music with
## a changing BPM.
@export var bpm: float = 60.0
## Audio bus index that the music should be played from (see Audio tab
## at the bottom of the editor). For example, "Master" is index 0.
@export var bus_index := 0:
	set(val):
		bus_index = val
		audio_changed.emit()
## Index of the SpectrumAnalyzer effect within the audio bus. [b]This is 
## required for audio to be visualized![/b]
@export var spectrum_analyzer_effect_index := 0:
	set(val):
		spectrum_analyzer_effect_index = val
		audio_changed.emit()

@export_subgroup("Analyzer")
## The number of frequency ranges that the visualizer will check
## during visualizing calculations. In general, more segments means
## a more "stable" visualization.
@export_range(1, 12, 1) var segments := 4:
	set(val):
		segments = val
		visuals_changed.emit()
## The lowest frequency that is checked during visualization.
@export var freq_min := 32.0:
	set(val):
		freq_min = val
		visuals_changed.emit()
## The highest frequency that is checked during visualization.
@export var freq_max := 8000.0:
	set(val):
		freq_max = val
		visuals_changed.emit()
## The curve along which frequency segments are sampled for analysis.
## This is nonlinear because frequencies are perceived nonlinearly.
## For example, you can easily tell the difference between 50 and 60 hertz,
## but not between 2050 and 2060 hertz, so it would be better to
## make smaller segments for lower frequencies.
## [br][br]
## In general, Quadratic should always be used.
@export var freq_curve: FreqCurv = FreqCurv.QUADRATIC:
	set(val):
		freq_curve = val
		visuals_changed.emit()
## Smallest decibel volume that will be considered in analysis.
## In other words, volume lower than this will not be visualized.
@export_range(-120.0, 0.0, 0.1) var min_db := -60.0:
	set(val):
		min_db = val
		visuals_changed.emit()
## Largest decibel volume that will be considered in analysis.
## In other words, any volume louder than this will be considered
## max volume.
@export_range(-120.0, 0.0, 0.1) var max_db := -20.0:
	set(val):
		max_db = val
		visuals_changed.emit()
## How quickly a frequency segment's stored volume will decay back to 0.
@export_range(0.0, 10.0, 0.01) var decay_speed := 1.0:
	set(val):
		decay_speed = val
		visuals_changed.emit()
## How quickly an energy segment's store volume will be increased when
## current volume is greater than the stored volume.
@export_range(0.0, 10.0, 0.01) var grow_speed := 2.0:
	set(val):
		grow_speed = val
		visuals_changed.emit()
## How frequency segments are combined for a final "energy" level
## for the music being played. 
@export var eval_type: EvalType = EvalType.MAX:
	set(val):
		eval_type = val
		visuals_changed.emit()
## How the combined "energy" level is scaled. In general,
## these determine how "easy" it is to reach max energy.
@export var eval_curve: EvalCurve = EvalCurve.LINEAR:
	set(val):
		eval_curve = val
		visuals_changed.emit()


@export_group("Visuals")
## Frames per second (FPS) that the visualizer is drawn.
@export var fps := 24

@export_subgroup("Art", "art_")
## Art being displayed. [b]This is required![b]
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
## Space between art and speaker(s).
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
@export var speaker_partitions_color: Color = Color.WHITE:
	set(val):
		speaker_partitions_color = val
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
@export var antenna_placement: AntennaPlacement = AntennaPlacement.RIGHT:
	set(val):
		antenna_placement = val
		visuals_changed.emit()
@export_range(0, 64, 1) var antenna_position = 16:
	set(val):
		antenna_position = val
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

@export_subgroup("Antenna Beat Bump", "antenna_beat_bump_")
@export var antenna_beat_bump_enabled := false:
	set(val):
		antenna_beat_bump_enabled = val
		visuals_changed.emit()
@export_range(-90.0, 90.0) var antenna_beat_bump_angle = 30.0:
	set(val):
		antenna_beat_bump_angle = val
		visuals_changed.emit()
@export_range(0.0, 1.0) var antenna_beat_bump_length = 0.5:
	set(val):
		antenna_beat_bump_length = val
		visuals_changed.emit()
@export_range(0.0, 1.0) var antenna_beat_bump_start = 0.0:
	set(val):
		antenna_beat_bump_start = val
		visuals_changed.emit()
@export_range(0.0, 1.0) var antenna_beat_bump_in_length = 0.1:
	set(val):
		if antenna_beat_bump_out_length:
			antenna_beat_bump_in_length = min(val, 1.0 - antenna_beat_bump_out_length)
		else:
			antenna_beat_bump_in_length = val
		visuals_changed.emit()
@export var antenna_beat_bump_in_trans: Tween.TransitionType = Tween.TransitionType.TRANS_QUAD:
	set(val):
		antenna_beat_bump_in_trans = val
		visuals_changed.emit()
@export var antenna_beat_bump_in_ease: Tween.EaseType = Tween.EaseType.EASE_OUT:
	set(val):
		antenna_beat_bump_in_ease = val
		visuals_changed.emit()
@export_range(0.0, 1.0) var antenna_beat_bump_out_length = 0.1:
	set(val):
		if antenna_beat_bump_in_length:
			antenna_beat_bump_out_length = min(val, 1.0 - antenna_beat_bump_in_length)
		else:
			antenna_beat_bump_out_length = val
		visuals_changed.emit()
@export var antenna_beat_bump_out_trans: Tween.TransitionType = Tween.TransitionType.TRANS_QUAD:
	set(val):
		antenna_beat_bump_out_trans = val
		visuals_changed.emit()
@export var antenna_beat_bump_out_ease: Tween.EaseType = Tween.EaseType.EASE_OUT:
	set(val):
		antenna_beat_bump_out_ease = val
		visuals_changed.emit()
