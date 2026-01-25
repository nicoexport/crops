@tool
class_name GameModel extends Resource

signal grid_resized(new_width: int, new_height: int)	
signal cell_changed(x: int, y: int, value)

signal irrigation_changed(x: int, y: int, level: int)	

@export var width: int = 8:
	set(v):
		if v != width:
			width = clamp(v, 0, 10)
			handle_grid_resize(width, height)
			grid_resized.emit(width, height)	
	get: 
		return width

@export var height: int = 8:
	set(v):
		if v != height:
			height = clamp(v, 0, 10)
			handle_grid_resize(width, height)
			grid_resized.emit(width, height)	
	get:
		return height	


var cells := {}
var irrigation_map := {}

func handle_grid_resize(new_width: int, new_height: int) -> void:
	# Adjust internal data structures as needed
	var new_cells := {}
	for x in range(new_width):
		for y in range(new_height):
			var key = Vector2i(x, y)
			if key in cells:
				new_cells[key] = cells[key]
			else:
				new_cells[key] = 0  # Default value for new cells
	cells = new_cells

	var new_irrigation_map := {}
	for x in range(new_width):
		for y in range(new_height):
			var key = Vector2i(x, y)
			if key in irrigation_map:
				new_irrigation_map[key] = irrigation_map[key]
			else:
				new_irrigation_map[key] = 0  # Default irrigation level
	irrigation_map = new_irrigation_map	


func set_cell(x: int, y: int, value: int) -> void:
	cells[Vector2i(x, y)] = value
	cell_changed.emit(x, y, value)	


func set_irrigation_level(x: int, y: int, level: int) -> void:
	level = clamp(level, 0, 5)	
	irrigation_map[Vector2i(x, y)] = level
	irrigation_changed.emit(x, y, level)


func add_irrigation_level(x: int, y: int, delta: int) -> void:
	var current_level: int = 0
	if Vector2i(x, y) in irrigation_map:
		current_level = irrigation_map[Vector2i(x, y)]
	var new_level = clamp(current_level + delta, 0, 5)
	irrigation_map[Vector2i(x, y)] = new_level
	irrigation_changed.emit(x, y, new_level)		