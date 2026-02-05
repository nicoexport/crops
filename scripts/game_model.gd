@tool
class_name GameModel extends Resource

enum State {NULL, START_GAME, START_TURN, TURN, END_TURN}

signal grid_resized(new_width: int, new_height: int)	
signal cell_changed(x: int, y: int, value)
signal irrigation_changed(x: int, y: int, level: int)
signal cell_entity_changed(x: int, y:int, entity)	

var state: State = State.NULL
var intend_end_turn: bool = false

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


func process(delta: float) -> void:
	process_state(state, delta)	


func change_state(p_state: State):
	exit_state(state)
	state = p_state
	enter_state(state)


func enter_state(p_state: State):
	match p_state:
		State.START_GAME:
			print("Entering START_GAME state")
			# Initialize game state, reset variables, etc.
			reset_model()
			grid_resized.emit(width, height)  # Notify views to rebuild grid
			change_state(State.START_TURN)  # Automatically transition to first turn
		State.START_TURN:
			print("Entering START_TURN state")
			await start_turn()
			change_state(State.TURN)
		State.TURN:
			print("Entering TURN state")
			# Wait for player input or AI actions here
			# For simplicity, we'll just wait for a short time and then end the turn

		State.END_TURN:
			print("Entering END_TURN state")
			end_turn()
			change_state(State.START_TURN)
		_:
			print("Entering NULL or unknown state")


func process_state(p_state: State, delta: float):
	match p_state:
		State.TURN:
			if intend_end_turn:
				change_state(State.END_TURN)
				intend_end_turn = false
		_:
			intend_end_turn = false
			pass	


func exit_state(p_state: State):
	match p_state:
		State.START_GAME:
			print("Exiting START_GAME state")
			# Clean up any temporary data if needed
		State.START_TURN:
			print("Exiting START_TURN state")
			# Prepare for turn actions if needed
		State.TURN:
			print("Exiting TURN state")
			# Finalize player actions if needed
		State.END_TURN:
			print("Exiting END_TURN state")
			# Reset any end-of-turn effects if needed
		_:
			print("Exiting NULL or unknown state")



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


func start_turn() -> void:
	print("--- starting turn ---")
	for key in cell_entity_map.keys():
		var entity: CellEntity = cell_entity_map[key]
		if entity != null:
			entity.on_turn_start(key.x, key.y, self)
			await Timers.wait_for(0.1)  # Small delay to simulate time taken for each entity's action


func end_turn() -> void:
	print("--- ending turn ---")
	# decrease water levels or other end-of-turn effects can be handled here
	for key in irrigation_map.keys():
		var current_level: int = irrigation_map[key]
		if current_level > 0:
			set_irrigation_level(key.x, key.y, current_level - 1)

	for key in cell_entity_map.keys():
		var entity: CellEntity = cell_entity_map[key]
		if entity != null:
			entity.on_turn_end(key.x, key.y, self)


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
	print("Irrigation level at (", x, ",", y, ") changed to ", new_level)	


func add_irrigation_to_area(center_x: int, center_y: int, delta: int) -> void:
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var x = center_x + dx
			var y = center_y + dy
			if Vector2i(x, y) in irrigation_map:
				add_irrigation_level(x, y, delta)


func try_place_entity_on_map(x: int, y: int, entity: CellEntity) -> bool:
	var key = Vector2i(x, y)
	if key in cell_entity_map and cell_entity_map[key] != null:
		return false
	
	cell_entity_map[key] = entity
	cell_entity_changed.emit(x, y, entity)
	print("Placed entity ", entity.name, " at (", x, ",", y, ")")
	return true


func try_remove_entity_from_map(x: int, y: int) -> bool:
	var key = Vector2i(x, y)
	if key in cell_entity_map and cell_entity_map[key] != null:
		cell_entity_map[key] = null
		cell_entity_changed.emit(x, y, null)
		print("Removed entity from (", x, ",", y, ")")
		return true
	return false	
