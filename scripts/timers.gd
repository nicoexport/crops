extends Node


func wait_for(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	