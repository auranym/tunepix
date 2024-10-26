@tool
class_name RadioConfig extends Resource

enum ColorTheme {
	LIGHT,
	DARK,
}

@export_group("Art", "art_")
@export var art: Texture2D:
	set(val):
		art = val
		emit_changed()
@export var art_outline := true:
	set(val):
		art_outline = val
		emit_changed()

@export_group("Colors", "color_")
@export var color_light: Color = Color.WHITE:
	set(val):
		color_light = val
		emit_changed()
@export var color_med: Color = Color.GRAY:
	set(val):
		color_med = val
		emit_changed()
@export var color_dark: Color = Color.BLACK:
	set(val):
		color_dark = val
		emit_changed()
@export var color_theme: ColorTheme = ColorTheme.LIGHT:
	set(val):
		color_theme = val
		emit_changed()

@export_group("Spacing")
@export_range(0, 32, 1) var padding := 8:
	set(val):
		padding = val
		emit_changed()
@export_range(0, 32, 1) var border_radius := 8:
	set(val):
		border_radius = val
		emit_changed()
@export_range(0, 32, 1) var gap := 8:
	set(val):
		gap = val
		emit_changed()

@export_group("Speaker", "speaker_")
@export var speaker_outline := false:
	set(val):
		speaker_outline = val
		emit_changed()
@export_range(1, 64, 1) var speaker_radius := 24:
	set(val):
		speaker_radius = val
		emit_changed()
@export_range(1, 64, 1) var speaker_bump_radius := 16:
	set(val):
		speaker_bump_radius = val
		emit_changed()
@export_range(0, 8, 1) var speaker_partitions := 4:
	set(val):
		speaker_partitions = val
		emit_changed()

@export_group("Antenna", "antenna_")
@export var antenna_visible := true:
	set(val):
		antenna_visible = val
		emit_changed()
@export_range(0, 256, 1) var antenna_length = 64:
	set(val):
		antenna_length = val
		emit_changed()
@export_range(0, 16, 1) var antenna_width = 4:
	set(val):
		antenna_width = val
		emit_changed()
@export_range(0, 32, 1) var antenna_receiver_radius = 2:
	set(val):
		antenna_receiver_radius = val
		emit_changed()
@export_range(0, 90, 1) var antenna_angle = 30:
	set(val):
		antenna_angle = val
		emit_changed()
