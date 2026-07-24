extends Node

var signals: Dictionary = {}

func connect_signal(signalName: StringName, callable: Callable):
	signals.get_or_add(signalName, []).append(callable)

func emit(eventName: StringName, args := []):
	for c: Callable in signals.get(eventName, []):
		c.callv(args)
