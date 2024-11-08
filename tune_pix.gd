@tool
extends Control

@export var config: TunePixConfig:
	set(val):
		if config != null:
			config.audio_changed.disconnect(_on_config_audio_changed)
			config.visuals_changed.disconnect(_on_config_visuals_changed)
		config = val
		if config:
			config.audio_changed.connect(_on_config_audio_changed)
			config.visuals_changed.connect(_on_config_visuals_changed)

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Private vars
var _energies
var _frame_time_elapsed: float = 1.0
var _beat_time_elapsed: float = 0.0
var _analyzer: AudioEffectSpectrumAnalyzerInstance
var _bump_energy: float = 0.0
var _beat_energy: float = 0.0
var _box_rect: Rect2


func _ready() -> void:
	_update_audio()
	_update_visuals()
	queue_redraw()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_beat_time_elapsed += delta
	var beat_in_ms = _get_beat_in_secs()
	if _beat_time_elapsed >= beat_in_ms:
		_beat_time_elapsed -= beat_in_ms
	
	_frame_time_elapsed += delta
	if _frame_time_elapsed > (1.0 / float(config.fps)):
		_bump_energy = _get_bump_energy()
		_frame_time_elapsed = 0
		queue_redraw()


# Audio functions
# ---------------
func _update_audio():
	# Stop current
	_analyzer = null
	audio_stream_player.stop()
	
	# Do nothing if there is no audio
	if not (config and config.stream):
		print("No audio to play.")
		return
	
	# Do nothing if there is no spectrum analyzer
	var analyzer = AudioServer.get_bus_effect_instance(config.bus_index, config.spectrum_analyzer_effect_index)
	if not analyzer is AudioEffectSpectrumAnalyzerInstance:
		print("Spectrum analyzer effect could not be found.")
		return
	
	# Set energies
	_energies = []
	_energies.resize(config.segments)
	_energies.fill(0.0)
	_analyzer = analyzer
	
	# Start playing if not in editor
	if not Engine.is_editor_hint():
		audio_stream_player.bus = AudioServer.get_bus_name(config.bus_index)
		audio_stream_player.stream = config.stream
		audio_stream_player.play()


func _get_bump_energy():
	if not _analyzer:
		return 0.0
	
	var total = 0.0
	var max = 0.0
	for i in config.segments:
		var magnitude = _analyzer.get_magnitude_for_frequency_range(_get_freq(i / float(config.segments)), _get_freq((i+1) / float(config.segments))).length()
		var energy = clampf((config.min_db + config.max_db - linear_to_db(magnitude)) / config.min_db, 0, 1)
		var speed
		if energy > _energies[i]:
			speed = config.grow_speed * _frame_time_elapsed
		else:
			speed = config.decay_speed * _frame_time_elapsed
		_energies[i] = move_toward(_energies[i], energy, speed)
		
		total += _energies[i]
		max = max(max, _energies[i])
	
	var eval = max
	if config.eval_type == TunePixConfig.EvalType.AVERAGE:
		eval = total / float(config.segments)
	if config.eval_curve == TunePixConfig.EvalCurve.QUADRATIC:
		eval = pow(eval, 2)
	elif config.eval_curve == TunePixConfig.EvalCurve.CUBIC:
		eval = pow(eval, 3)
	
	return eval


## X should be between 0 and 1
func _get_freq(x):
	var weight
	
	# Sigmoid
	if config.freq_curve == TunePixConfig.FreqCurv.SIGMOID:
		weight = (
			1 / (
				1 + exp(
					-4 * exp(1) * (x - 0.5)
				)
			)
		)
	# Quadratic
	else:
		weight = pow(x, 2)
	
	return lerp(config.freq_min, config.freq_max, weight)


func _get_beat_in_secs():
	if config.bpm == 0.0:
		return INF
	return 60.0 / config.bpm


func _get_beat_energy():
	return clamp(_beat_time_elapsed / _get_beat_in_secs(), 0.0, 1.0)


# Visuals functionss
# -----------------
func _update_visuals():
	_set_radio_size()


func _set_radio_size():
	if config and config.art_texture:
		# Calculate antenna bounding box height
		var antenna_rect_height = round(
			abs((config.antenna_length * Vector2.from_angle(deg_to_rad(config.antenna_angle + 180))).y)
			# Not sure why 3 is the right multiplier, but it works!
			+ 3 * config.antenna_receiver_radius
		)
		
		var speaker_length = 2 * (config.speaker_radius + config.speaker_bump_radius)
		var width = (
			config.art_texture.get_width()
			+ config.box_gap
			+ speaker_length
			+ config.speaker_padding
		)
		if config.speaker_placement == RadioConfig.SpeakerPlacement.BOTH:
			width += (
				config.box_gap
				+ speaker_length
				+ config.speaker_padding
			)
		else:
			width += config.art_padding
		
		var height = max(
			2 * config.art_padding + config.art_texture.get_height(),
			2 * config.speaker_padding + speaker_length
		)
		
		_box_rect = Rect2(
			Vector2(0, antenna_rect_height),
			Vector2(width, height)
		)
	else:
		_box_rect = Rect2()
	
	size = _box_rect.position + _box_rect.size


func _draw():
	if not (config and config.art_texture):
		return
	
	if config.antenna_visible:
		_draw_antenna()
	_draw_background()
	_draw_speakers()
	_draw_displayed_texture()


func _draw_rounded_rect(rect: Rect2, color: Color, radius: float):
	var p = rect.position
	var s = rect.size
	
	# Border radii
	# ------------
	# Top-left
	draw_circle(
		p + Vector2(radius, radius),
		radius,
		color
	)
	# Top-right
	draw_circle(
		p + Vector2(s.x - radius, radius),
		radius,
		color
	)
	# Bottom-left
	draw_circle(
		p + Vector2(radius, s.y - radius),
		radius,
		color
	)
	# Bottom-right
	draw_circle(
		p + s - Vector2(radius, radius),
		radius,
		color
	)
	
	# Background
	# ----------
	draw_rect(
		Rect2(p + Vector2(0, radius), s - Vector2(0, 2 * radius)),
		color
	)
	draw_rect(
		Rect2(p + Vector2(radius, 0), s - Vector2(2 * radius, 0)),
		color
	)


func _get_beat_bump_angle_offset():
	if Engine.is_editor_hint() or config.antenna_beat_bump_length == 0.0:
		return 0.0
	
	var elapsed = fposmod(
		_get_beat_energy() + config.antenna_beat_bump_start
		, 1.0
	) / config.antenna_beat_bump_length
	
	# In
	if elapsed < config.antenna_beat_bump_in_length:
		return Tween.interpolate_value(
			0.0,
			config.antenna_beat_bump_angle,
			elapsed,
			config.antenna_beat_bump_in_length,
			config.antenna_beat_bump_in_trans,
			config.antenna_beat_bump_in_ease
		)
	
	# Hold
	elif elapsed < 1.0 - config.antenna_beat_bump_out_length:
		return config.antenna_beat_bump_angle
	
	# Out
	elif elapsed < 1.0:
		return Tween.interpolate_value(
			config.antenna_beat_bump_angle,
			- config.antenna_beat_bump_angle,
			elapsed - (1.0 - config.antenna_beat_bump_out_length),
			config.antenna_beat_bump_out_length,
			config.antenna_beat_bump_out_trans,
			config.antenna_beat_bump_out_ease
		)
	
	# Base
	else:
		return 0.0


func _draw_antenna():
	var beat_angle_offset = _get_beat_bump_angle_offset() if config.antenna_beat_bump_enabled else 0.0
	var unit_vector = Vector2.from_angle(deg_to_rad(
		clamp(
			config.antenna_angle + 180 + beat_angle_offset,
			180,
			270
		)
	))
	var start_pos = Vector2(
		_box_rect.position.x + _box_rect.size.x - config.speaker_padding - config.speaker_bump_radius - config.speaker_radius,
		_box_rect.position.y - config.antenna_width / 2.0
	)
	# Connector
	draw_line(
		start_pos,
		start_pos + Vector2(0, config.antenna_width / 2.0),
		config.antenna_color,
		config.antenna_width
	)
	draw_circle(
		start_pos,
		config.antenna_width / 2.0,
		config.antenna_color
	)
	
	# Antenna
	draw_line(
		start_pos,
		start_pos + round(config.antenna_length * unit_vector),
		config.antenna_color,
		config.antenna_width
	)
	
	# Receiver
	draw_circle(
		start_pos + round(config.antenna_length * unit_vector),
		config.antenna_width / 2.0 + config.antenna_receiver_radius,
		config.antenna_receiver_color
	)


func _draw_background():
	_draw_rounded_rect(
		_box_rect,
		config.box_color,
		config.box_border_radius
	)


func _draw_speakers():
	var speaker_max_radius = config.speaker_radius + config.speaker_bump_radius
	var speaker_y_pos
	match config.speaker_alignment:
		RadioConfig.SpeakerAlignment.TOP:
			speaker_y_pos = _box_rect.position.y + config.speaker_padding
		RadioConfig.SpeakerAlignment.CENTER:
			speaker_y_pos = _box_rect.position.y + _box_rect.size.y / 2.0 - speaker_max_radius
		RadioConfig.SpeakerAlignment.BOTTOM:
			speaker_y_pos = _box_rect.position.y + _box_rect.size.y - config.speaker_padding - 2 * speaker_max_radius
		
	# Draw left speaker
	if config.speaker_placement != RadioConfig.SpeakerPlacement.RIGHT:
		_draw_speaker(
			Vector2(
				_box_rect.position.x + config.speaker_padding,
				speaker_y_pos
			)
		)
	# Draw right speaker
	if config.speaker_placement != RadioConfig.SpeakerPlacement.LEFT:
		_draw_speaker(
			Vector2(
				_box_rect.position.x + _box_rect.size.x - config.speaker_padding - 2 * speaker_max_radius,
				speaker_y_pos
			)
		)


# pos is top-left
func _draw_speaker(pos: Vector2):
	var speaker_max_radius = config.speaker_radius + config.speaker_bump_radius
	var speaker_animated_dist = _bump_energy * config.speaker_bump_radius
	var speaker_animated_radius = config.speaker_radius + speaker_animated_dist
	
	# Speaker circle
	draw_circle(
		pos + Vector2(speaker_max_radius, speaker_max_radius),
		speaker_animated_radius,
		config.speaker_color
	)
	# Speaker partitions
	var partition_base_position = pos + Vector2(
		config.speaker_bump_radius - speaker_animated_dist,
		config.speaker_bump_radius - speaker_animated_dist
	)
	var partition_width = 2 * speaker_animated_radius / float(2 * config.speaker_partitions + 1)
	for i in (2 * config.speaker_partitions + 1):
		if i % 2 == 1:
			draw_rect(
				Rect2(
					partition_base_position + Vector2(0, i * partition_width),
					Vector2(2 * speaker_animated_radius, partition_width)
				),
				config.box_color
			)
	# Speaker outline
	if config.speaker_outline:
		draw_circle(
			pos + Vector2(speaker_max_radius, speaker_max_radius),
			speaker_animated_radius + 1,
			config.speaker_outline_color,
			false,
			config.speaker_outline_size
		)


func _draw_displayed_texture():
	var art_size = config.art_texture.get_size()
	var art_position = _box_rect.position + Vector2(
		config.art_padding if config.speaker_placement == RadioConfig.SpeakerPlacement.RIGHT else (
			config.speaker_padding + 2 * (config.speaker_radius + config.speaker_bump_radius) + config.box_gap
		),
		config.art_padding
	)
	var outline_size = config.art_outline_size
	if config.art_outline:
		_draw_rounded_rect(
			Rect2(
				art_position - Vector2(outline_size, outline_size),
				art_size + 2 * Vector2(outline_size, outline_size)
			),
			config.art_outline_color,
			outline_size
		)
	draw_texture(config.art_texture, art_position)


# Signal callbacks
# ----------------
func _on_config_audio_changed():
	if Engine.is_editor_hint():
		return
	_update_audio()
	_update_visuals()
	queue_redraw()

func _on_config_visuals_changed():
	_update_visuals()
	queue_redraw()
