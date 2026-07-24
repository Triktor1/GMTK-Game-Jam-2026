@tool
extends Control

@export var target: Control
@export var target_property: String = "propiedad"
@export var scale_x: float = 1.2
@export var scale_y: float = 1.2
@export var rot_degrees: int = 15
@export var time_go_x: float = 0.1
@export var time_go_y: float = 0.15
@export var time_go_rot: float = 0.1
@export var time_back_x: float = 0.2
@export var time_back_y: float = 0.3
@export var time_back_rot: float = 0.1

var tween: Tween	

func _set(property: StringName, value: Variant) -> bool:
	if !target: target = self
	if property == target_property:
		# Only animate if property changes
		if get(property) == value: return false
		_animate()
		return false
	return false

# Animate once and return to original values
func _animate() -> void:
	pivot_offset = size / 2.0
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(target, "scale:x", scale_x, time_go_x)
	tween.parallel().tween_property(target, "scale:y", scale_y, time_go_y)
	tween.parallel().tween_property(target, "rotation_degrees", rot_degrees * [-1, 1].pick_random(), time_go_rot)
	tween.parallel().tween_property(target, "scale:x", 1.0, time_back_x).set_delay(time_go_x+0.1)
	tween.parallel().tween_property(target, "scale:y", 1.0, time_back_y).set_delay(time_go_y+0.1)
	tween.parallel().tween_property(target, "rotation_degrees", 0, time_back_rot).set_delay(time_go_rot+0.05)
