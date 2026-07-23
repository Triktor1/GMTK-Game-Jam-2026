@tool
extends Control

@export var target_property: String = "propiedad"

signal hola;

var tween: Tween	

func _set(property: StringName, value: Variant) -> bool:
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
	tween.tween_property(self, "scale:x", 1.2, 0.1)
	tween.parallel().tween_property(self, "scale:y", 1.2, 0.15)
	tween.parallel().tween_property(self, "rotation_degrees", 15 * [-1, 1].pick_random(), 0.1)
	tween.parallel().tween_property(self, "scale:x", 1.0, 0.2).set_delay(0.2)
	tween.parallel().tween_property(self, "scale:y", 1.0, 0.3).set_delay(0.25)
	tween.parallel().tween_property(self, "rotation_degrees", 0, 0.1).set_delay(0.15)
