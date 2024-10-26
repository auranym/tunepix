class_name VisualizerConfig extends Resource

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

@export_range(1, 12, 1) var segments := 4
@export var freq_min := 32.0
@export var freq_max := 8000.0
@export var freq_curve: FreqCurv = FreqCurv.QUADRATIC
@export_range(-120.0, 0.0, 0.1) var min_db := -60.0
@export_range(-120.0, 0.0, 0.1) var max_db := -20.0
@export_range(0.0, 10.0, 0.01) var decay_speed := 1.0
@export_range(0.0, 10.0, 0.01) var grow_speed := 2.0
@export var eval_type: EvalType = EvalType.MAX
@export var eval_curve: EvalCurve = EvalCurve.LINEAR
