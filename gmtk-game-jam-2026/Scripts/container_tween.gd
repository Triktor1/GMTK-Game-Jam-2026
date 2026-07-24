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
	SLIDE_IN_TOP,
	SLIDE_IN_BOTTOM,
	##Elements will scale from 0 to 1
	SCALE,
	##Elements will alternate between sliding from the left and right, starting in the left
	SHUFFLE_FROM_LEFT,
	##Elements will alternate between sliding from the left and right, starting in the right
	SHUFFLE_FROM_RIGHT,
	##Elements will alternate between sliding from the top and bottom, starting in the top
	SHUFFLE_FROM_TOP,
	##Elements will alternate between sliding from the top and bottom, starting in the bottom
	SHUFFLE_FROM_BOTTOM
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
var original_positions: Array[Vector2]

func _ready() -> void:
	# If target isn't assigned, defaults to parent node
	if !target:
		target = self
	
	# Assume nodes can't have more than one container_tween
	target.set_meta("container_tween", self)
	
	for c: Control in get_children():
		original_positions.push_back(c.position)
	
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
	disappear()
	var children: Array = target.get_children()
	
	#Call set_pivot again in case size changed
	for c: Control in children:
		set_pivot(c, scale_from)
	
	#If tween is already doing something we KILL IT RUTHLESSLY (and remake it)
	if tween && tween.is_running():
		tween.kill()
		var i: int = 0
		for c: Control in children:
			c.position = original_positions[i]
			i+=1
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(true)
	
	if delay_appear > 0.0:
		tween.tween_interval(delay_appear)
		tween.chain().tween_interval(0.01)
	
	if order_type == ORDER_TYPE.START_BOTTOM:
		children.reverse()
		original_positions.reverse()
		
	var cont: int = -1
	if anim_type == ANIM_TYPE.SHUFFLE_FROM_RIGHT || anim_type == ANIM_TYPE.SHUFFLE_FROM_BOTTOM:
		cont *= -1
		
	var idx: int = 0
	for c: Control in children:
		match anim_type:
			ANIM_TYPE.SCALE:
				tween.tween_property(c, "scale", Vector2.ONE, duration).from(Vector2.ZERO).set_delay(delay_between_elems*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.01).set_delay(delay_between_elems*idx)
			ANIM_TYPE.SLIDE_IN_LEFT:
				tween.tween_property(c, "position:x", c.position.x, duration).from(c.position.x-c.size.x).set_delay(delay_between_elems*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elems*idx)
			ANIM_TYPE.SLIDE_IN_RIGHT:
				tween.tween_property(c, "position:x", c.position.x, duration).from(c.position.x+c.size.x).set_delay(delay_between_elems*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elems*idx)
			ANIM_TYPE.SLIDE_IN_TOP:
				tween.tween_property(c, "position:y", c.position.y, duration).from(c.position.y-c.size.y).set_delay(delay_between_elems*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elems*idx)
			ANIM_TYPE.SLIDE_IN_BOTTOM:
				tween.tween_property(c, "position:y", c.position.y, duration).from(c.position.y+c.size.y).set_delay(delay_between_elems*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elems*idx)
			ANIM_TYPE.SHUFFLE_FROM_LEFT, ANIM_TYPE.SHUFFLE_FROM_RIGHT:
				tween.tween_property(c, "position:x", c.position.x, duration).from(c.position.x+(c.size.x*cont)).set_delay(delay_between_elems*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elems*idx)
				cont *= -1
			ANIM_TYPE.SHUFFLE_FROM_TOP, ANIM_TYPE.SHUFFLE_FROM_BOTTOM:
				tween.tween_property(c, "position:y", c.position.x, duration).from(c.position.y+(c.size.y*cont)).set_delay(delay_between_elems*idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05).set_delay(delay_between_elems*idx)
				cont *= -1
			
		
		idx += 1

func disappear():
	var children: Array = get_children()
	for c: Control in children:
		c.modulate.a = 0
