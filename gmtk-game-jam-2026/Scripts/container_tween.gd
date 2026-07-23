extends Control

enum ANIM_WHEN{
	##When _ready function is called
	READY,
	##When signal "paused_game" is emitted
	SIGNAL
}

enum ANIM_TYPE{
	##Elements will slide from the left
	SLIDE_IN_LEFT,
	##Elements will slide from the right
	SLIDE_IN_RIGHT,
	##Elements will scale from 0 to 1
	SCALE
}

enum ORDER_TYPE{
	##Elements will animate starting from the top of the children
	START_TOP,
	##Elements will animate starting from the bottom of the children
	START_BOTTOM
}

enum SCALE_FROM{
	CENTER,
	TOP_LEFT,
	TOP,
	TOP_RIGHT,
	LEFT,
	RIGHT,
	BOTTOM_LEFT,
	BOTTOM,
	BOTTOM_RIGHT
}

## Parent container that will have its children tweened in a sequence (usually it will be the node that has this script)
@export var target: Control
## When the animation is called
@export var anim_when: ANIM_WHEN = ANIM_WHEN.READY
## Name of the signal that will be emitted to start aniamtion (only used if anim_when = SIGNAL)
@export var enter_signal_name: StringName = "enter_signal"
## Name of the signal that will be emitted to reset object modulation (this one is always used)
@export var exit_signal_name: StringName = "exit_signal"
## Type of animation
@export var anim_type: ANIM_TYPE = ANIM_TYPE.SCALE
##The order in which the elements will be animated
@export var order_type: ORDER_TYPE = ORDER_TYPE.START_TOP
## Pivot of the scale. Will only be used if Anim Type is Scale
@export var scale_from: SCALE_FROM = SCALE_FROM.CENTER
## Duration of each individual animation
@export var duration: float = 0.2
## Delay before showing the elements and starting the animation
@export var delay_appear: float = 0.2
## Delay between element animation
@export var delay_between_elems: float = 0.05

var tween: Tween

func _ready() -> void:
	# If target isn't assigned, defaults to parent node
	if !target:
		target = self
	
	# Assume nodes can't have more than one container_tween
	target.set_meta("container_tween", self)
	
	match anim_type:
		ANIM_TYPE.SCALE:
			for c: Control in target.get_children():
				c.scale = Vector2.ZERO # Will get overriden by tweens later on
				# Transparent and not hidden so that the container doesn't recalculate positions
				c.modulate.a = 0
		ANIM_TYPE.SLIDE_IN_LEFT, ANIM_TYPE.SLIDE_IN_RIGHT:
			for c: Control in target.get_children():
				c.modulate.a = 0
	
	if anim_type == ANIM_TYPE.SCALE:
		for c: Control in target.get_children():
			set_pivot(c, scale_from)
	
	if anim_when == ANIM_WHEN.READY:
		appear.call_deferred()
	elif anim_when == ANIM_WHEN.SIGNAL:
		EventBus.connect_signal(enter_signal_name, appear)
		
	EventBus.connect_signal(exit_signal_name, disappear)

func set_pivot(control: Control, pivot: SCALE_FROM) -> void:
	match pivot:
		SCALE_FROM.CENTER:
			control.pivot_offset = Vector2(0.0, 0.0)
		SCALE_FROM.TOP_LEFT:
			control.pivot_offset = Vector2(-control.size.x / 2.0, -control.size.y / 2.0)
		SCALE_FROM.TOP:
			control.pivot_offset = Vector2(0.0, -control.size.y / 2.0)
		SCALE_FROM.TOP_RIGHT:
			control.pivot_offset = Vector2(control.size.x / 2.0, -control.size.y / 2.0)
		SCALE_FROM.LEFT:
			control.pivot_offset = Vector2(-control.size.x / 2.0, 0.0)
		SCALE_FROM.RIGHT:
			control.pivot_offset = Vector2(control.size.x / 2.0, 0.0)
		SCALE_FROM.BOTTOM_LEFT:
			control.pivot_offset = Vector2(-control.size.x / 2.0, control.size.y)
		SCALE_FROM.BOTTOM:
			control.pivot_offset = Vector2(0.0, control.size.y / 2.0)
		SCALE_FROM.BOTTOM_RIGHT:
			control.pivot_offset = Vector2(control.size.x / 2.0, control.size.y / 2.0)

func appear() -> void:
	var children: Array = target.get_children()
	
	#Call set_pivot again in case size changed
	for c: Control in children:
		set_pivot(c, scale_from)
	
	#If tween is already doing something we KILL IT RUTHLESSLY (and remake it)
	if tween && tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	
	if delay_appear > 0.0:
		tween.tween_interval(delay_appear)
		tween.chain().tween_interval(0.01)
	
	if order_type == ORDER_TYPE.START_BOTTOM:
		children.reverse()
	
	var idx: int = 0
	for c: Control in children:
		if anim_type == ANIM_TYPE.SCALE:
			tween.tween_property(c, "scale", Vector2.ONE, duration).from(Vector2.ZERO).set_delay(delay_between_elems*idx)
			tween.tween_property(c, "modulate:a", 1.0, 0.01).set_delay(delay_between_elems*idx)
		elif anim_type == ANIM_TYPE.SLIDE_IN_LEFT:
			tween.tween_property(c, "position:x", c.position.x, duration).from(c.position.x-c.size.x).set_delay(delay_between_elems*idx)
			tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elems*idx)
		elif anim_type == ANIM_TYPE.SLIDE_IN_RIGHT:
			tween.tween_property(c, "position:x", c.position.x, duration).from(c.position.x+c.size.x).set_delay(delay_between_elems*idx)
			tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elems*idx)
		
		idx += 1

func disappear():
	var children: Array = get_children()
	for c: Control in children:
		c.modulate.a = 0
