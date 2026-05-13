extends Control

@export var joystick_radius: float = 80.0

var touch_index: int = -1
var center_pos: Vector2
var output: Vector2 = Vector2.ZERO

@onready var knob: Control = $Knob
@onready var background: Control = $Background

func _ready():
	center_pos = background.position + background.size / 2
	knob.position = center_pos - knob.size / 2

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Проверяем, нажали ли в левую половину экрана
			if event.position.x < get_viewport_rect().size.x / 2:
				touch_index = event.index
				_update_knob(event.position)
		else:
			if event.index == touch_index:
				touch_index = -1
				_reset_knob()
	
	if event is InputEventScreenDrag:
		if event.index == touch_index:
			_update_knob(event.position)

func _update_knob(pos: Vector2):
	var offset = pos - center_pos
	offset = offset.limit_length(joystick_radius)
	knob.position = center_pos + offset - knob.size / 2
	output = offset / joystick_radius

func _reset_knob():
	knob.position = center_pos - knob.size / 2
	output = Vector2.ZERO

func get_velocity() -> Vector2:
	return output
