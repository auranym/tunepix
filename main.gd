extends Control

const WIDTH = 800
const HEIGHT = 400

@export_range(0, 60, 1) var redraws_per_second = 30
@export var visualizer_config: VisualizerConfig:
	get: return visualizer_config
	set(val):
		visualizer_config = val
		_set_energies()

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _energies
var _frame_time_elapsed: float = 1.0
var _analyzer: AudioEffectSpectrumAnalyzerInstance


func _set_energies():
	_energies = []
	_energies.resize(visualizer_config.segments)
	_energies.fill(0.0)


# Called when the node enters the scene tree for the first time.
func _ready():
	var index = AudioServer.get_bus_index("Analyzer")
	if index == -1:
		print("Did not find bus")
		return
	
	var analyzer = AudioServer.get_bus_effect_instance(index, 0)
	if not analyzer is AudioEffectSpectrumAnalyzerInstance:
		print("Value was not AudioEffectSpectrumAnalyzerInstance")
		return
	
	_set_energies()
	_analyzer = analyzer
	
	audio_stream_player.play()


func _draw():
	if not _analyzer:
		return
	
	var total = 0.0
	var max = 0.0
	
	for i in visualizer_config.segments:
		total += _energies[i]
		max = max(max, _energies[i])
		var width = WIDTH / visualizer_config.segments
		
		draw_rect(
			Rect2(i * width, 0, width - 2.0, _energies[i] * HEIGHT),
			Color.WHITE
		)
	
	var eval = max
	if visualizer_config.eval_type == VisualizerConfig.EvalType.AVERAGE:
		eval = total / float(visualizer_config.segments)
	if visualizer_config.eval_curve == VisualizerConfig.EvalCurve.QUADRATIC:
		eval = pow(eval, 2)
	elif visualizer_config.eval_curve == VisualizerConfig.EvalCurve.CUBIC:
		eval = pow(eval, 3)
	draw_circle(Vector2(WIDTH, HEIGHT), 60.0, Color.WEB_GRAY)
	draw_circle(Vector2(WIDTH, HEIGHT), eval * 60.0, Color.WHITE)


func _process(delta):
	if not _analyzer:
		return
	
	_frame_time_elapsed += delta
	if _frame_time_elapsed > (1.0 / float(redraws_per_second)):
		for i in visualizer_config.segments:
			var magnitude = _analyzer.get_magnitude_for_frequency_range(_get_freq(i / float(visualizer_config.segments)), _get_freq((i+1) / float(visualizer_config.segments))).length()
			var energy = clampf((visualizer_config.min_db + visualizer_config.max_db - linear_to_db(magnitude)) / visualizer_config.min_db, 0, 1)
			var speed
			if energy > _energies[i]:
				speed = visualizer_config.grow_speed * _frame_time_elapsed
			else:
				speed = visualizer_config.decay_speed * _frame_time_elapsed
			_energies[i] = move_toward(_energies[i], energy, speed)
		
		# Sound plays back continuously, so the graph needs to be updated every frame.
		queue_redraw()
		
		_frame_time_elapsed = 0


## X should be between 0 and 1
func _get_freq(x):
	var weight
	
	# Sigmoid
	if visualizer_config.freq_curve == VisualizerConfig.FreqCurv.SIGMOID:
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
	
	return lerp(visualizer_config.freq_min, visualizer_config.freq_max, weight)
