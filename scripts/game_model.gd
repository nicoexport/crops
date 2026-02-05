@tool
class_name GameModel extends Resource

signal grid_resized(new_width: int, new_height: int)	


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
var cell_entity_map := {}


func reset_model() -> void:
	cells.clear()
	irrigation_map.clear()
	cell_entity_map.clear()
	for x in range(width):
		for y in range(height):
			cells[Vector2i(x, y)] = 0  # Initialize cells to default value
			irrigation_map[Vector2i(x, y)] = 0  # Initialize irrigation levels
			cell_entity_map[Vector2i(x, y)] = null  # Initialize cell entities


func handle_grid_resize(new_width: int, new_height: int) -> void:
	# Adjust internal data structures as needed
	var new_cells := {}
	var new_irrigation_map := {}
	var new_cell_entity_map := {}


	for x in range(new_width):
		for y in range(new_height):
			var key = Vector2i(x, y)
			if key in cells:
				new_cells[key] = cells[key]
			else:
				new_cells[key] = 0  # Default value for new cells

			if key in irrigation_map:
				new_irrigation_map[key] = irrigation_map[key]
			else:
				new_irrigation_map[key] = 0  # Default irrigation level

			if key in cell_entity_map:
				new_cell_entity_map[key] = cell_entity_map[key]

	cells = new_cells
	irrigation_map = new_irrigation_map	
	cell_entity_map = new_cell_entity_map