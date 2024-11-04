@tool
extends Control

@export_range(0.0, 1.0) var bump_energy = 0.0:
	set(val):
		bump_energy = val
		queue_redraw()
@export var config: RadioConfig:
	set(val):
		if config:
			config.disconnect("changed", _update)
		
		config = val
		if config:
			config.changed.connect(_update)
		
		_update()

var _box_rect: Rect2
var _min_size: Vector2

func _update():
	_set_radio_size()
	queue_redraw()


func _get_minimum_size() -> Vector2:
	return _min_size


func _set_radio_size():
	if config and config.art:
		# Calculate antenna bounding box height
		var antenna_rect_height = round(
			abs((config.antenna_length * Vector2.from_angle(deg_to_rad(config.antenna_angle + 180))).y)
			# Not sure why 3 is the right multiplier, but it works!
			+ 3 * config.antenna_receiver_radius
		)
		
		var speaker_length = 2 * (config.speaker_radius + config.speaker_bump_radius)
		var width = (
			config.art.get_width()
			+ config.gap
			+ speaker_length
			+ config.speaker_padding
		)
		if config.speaker_placement == RadioConfig.SpeakerPlacement.BOTH:
			width += (
				config.gap
				+ speaker_length
				+ config.speaker_padding
			)
		else:
			width += config.art_padding
		
		var height = max(
			2 * config.art_padding + config.art.get_height(),
			2 * config.speaker_padding + speaker_length
		)
		
		_box_rect = Rect2(
			Vector2(0, antenna_rect_height),
			Vector2(width, height)
			#(
				#config.art.get_size()
				#+ Vector2(config.art_padding, config.art_padding)
				#+ Vector2(config.gap, 0)
				#+ Vector2(2 * (config.speaker_radius + config.speaker_bump_radius), 0)
			#)
		)
	else:
		_box_rect = Rect2()
	
	size = _box_rect.position + _box_rect.size
	_min_size = size


func _draw() -> void:
	if not (config and config.art):
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


func _draw_antenna():
	var unit_vector = Vector2.from_angle(deg_to_rad(config.antenna_angle + 180))
	var start_pos = Vector2(
		_box_rect.position.x + _box_rect.size.x - config.speaker_padding - config.speaker_bump_radius - config.speaker_radius,
		_box_rect.position.y - config.antenna_width / 2.0
	)
	var color = config.color_dark if config.color_theme == RadioConfig.ColorTheme.DARK else config.color_light
	# Connector
	draw_line(
		start_pos,
		start_pos + Vector2(0, config.antenna_width / 2.0),
		color,
		config.antenna_width
	)
	draw_circle(
		start_pos,
		config.antenna_width / 2.0,
		color
	)
	
	# Antenna
	draw_line(
		start_pos,
		start_pos + config.antenna_length * unit_vector,
		color,
		config.antenna_width
	)
	
	# Receiver
	draw_circle(
		start_pos + config.antenna_length * unit_vector,
		config.antenna_width / 2.0 + config.antenna_receiver_radius,
		color
	)


func _draw_background():
	_draw_rounded_rect(
		_box_rect,
		config.color_dark if config.color_theme == RadioConfig.ColorTheme.DARK else config.color_light,
		config.border_radius
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
	var speaker_animated_dist = 0 if not bump_energy else bump_energy * config.speaker_bump_radius
	var speaker_animated_radius = config.speaker_radius + speaker_animated_dist
	
	# Speaker circle
	draw_circle(
		pos + Vector2(speaker_max_radius, speaker_max_radius),
		speaker_animated_radius,
		config.color_dark if config.color_theme == RadioConfig.ColorTheme.LIGHT else config.color_light
	)
	# Speaker partitions
	var partition_base_position = pos + Vector2(
		config.speaker_bump_radius - speaker_animated_dist,
		config.speaker_bump_radius - speaker_animated_dist
	)
	#Vector2(
		#_box_rect.position.x + _box_rect.size.x - config.speaker_padding - speaker_max_radius - speaker_animated_radius,
		#_box_rect.position.y + config.speaker_padding + config.speaker_bump_radius - speaker_animated_dist
	#)
	var partition_width = 2 * speaker_animated_radius / float(2 * config.speaker_partitions + 1)
	for i in (2 * config.speaker_partitions + 1):
		if i % 2 == 1:
			draw_rect(
				Rect2(
					partition_base_position + Vector2(0, i * partition_width),
					Vector2(2 * speaker_animated_radius, partition_width)
				),
				config.color_light if config.color_theme == RadioConfig.ColorTheme.LIGHT else config.color_dark
			)
	# Speaker outline
	if config.speaker_outline:
		draw_circle(
			pos + Vector2(speaker_max_radius, speaker_max_radius),
			speaker_animated_radius + 1,
			config.color_med,
			false,
			2
		)


func _draw_displayed_texture():
	var art_size = config.art.get_size()
	var art_position = _box_rect.position + Vector2(
		config.art_padding if config.speaker_placement == RadioConfig.SpeakerPlacement.RIGHT else (
			config.speaker_padding + 2 * (config.speaker_radius + config.speaker_bump_radius) + config.gap
		),
		config.art_padding
	)
	if config.art_outline:
		_draw_rounded_rect(
			Rect2(
				art_position - Vector2(2, 2),
				art_size + Vector2(4, 4)
			),
			config.color_med,
			2
		)
	draw_texture(config.art, art_position)
