@tool
extends Control

@export var config: TunePixConfig:
	set(val):
		if config != null:
			config.audio_changed.disconnect(_on_config_audio_changed)
			config.visuals_changed.disconnect(_on_config_visuals_changed)
		config = val
		config.audio_changed.connect(_on_config_audio_changed)
		config.visuals_changed.connect(_on_config_visuals_changed)

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Private vars
var _started := false
var _energies
var _frame_time_elapsed: float = 1.0
var _analyzer: AudioEffectSpectrumAnalyzerInstance
var _bump_energy: float = 0.0


func _ready() -> void:
	if not Engine.is_editor_hint():
		_start()


func _process(delta: float) -> void:
	if not _started:
		return
	
	_frame_time_elapsed += delta
	if _frame_time_elapsed > (1.0 / float(config.fps)):
		_bump_energy = _get_bump_energy()
		_frame_time_elapsed = 0
		queue_redraw()


func _start():
	_started = true
	_update_audio()
	print("started")


# Audio functions
# ---------------
func _update_audio():
	# Stop current
	_analyzer = null
	audio_stream_player.stop()
	
	# Do nothing if there is no audio
	if not config.stream:
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
	
	# Start playing if started already
	if _started:
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


# Visuals functionss
# -----------------
func _update_visuals():
	pass


func _draw():
	draw_rect(Rect2(0, 0, 100 * (1 + _bump_energy), 100), Color.WHITE)


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
