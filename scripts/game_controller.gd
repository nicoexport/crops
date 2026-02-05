@tool
class_name GameController extends Node


enum State {NULL, START_GAME, START_TURN, TURN, END_TURN}

@export var model: GameModel:
	set(m):
		_disconnect_model_signals()
		model = m
		_connect_model_signals()
		
@export var view: GameView

var _state: State = State.NULL	
var intend_end_turn: bool = false
var _model_signals_connected: bool = false	


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		_process_state(_state, delta)


func perform_interaction_on_model(x: int, y: int, interaction: BaseInteraction) -> void:
	interaction.perform(x, y, self)


func change_state(p_state: State) -> void:
	_exit_state(_state)
	_state = p_state
	_enter_state(_state)


func increase_irrigation(x: int, y: int, amount: int) -> void:
	var current_level: int = 0
	if Vector2i(x, y) in model.irrigation_map:
		current_level = model.irrigation_map[Vector2i(x, y)]
	var new_level = clamp(current_level + amount, 0, 5)
	model.irrigation_map[Vector2i(x, y)] = new_level
	_on_irrigation_changed(x, y, new_level)


func increase_irrigation_in_area(center_x: int, center_y: int, amount: int) -> void:
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var x = center_x + dx
			var y = center_y + dy
			if Vector2i(x, y) in model.irrigation_map:
				increase_irrigation(x, y, amount)


func try_place_entity_on_map(x: int, y: int, entity: CellEntity) -> bool:
	var key = Vector2i(x, y)
	if key in model.cell_entity_map and model.cell_entity_map[key] != null:
		return false	
	model.cell_entity_map[key] = entity
	_on_cell_entity_changed(x, y, entity)
	return true


func try_remove_entity_from_map(x: int, y: int) -> bool:
	var key = Vector2i(x, y)
	if key in model.cell_entity_map and model.cell_entity_map[key] != null:
		model.cell_entity_map[key] = null
		_on_cell_entity_changed(x, y, null)
		return true
	return false	


func _process_state(p_state: State, _delta: float) -> void:
	match p_state:
		State.TURN:
			if intend_end_turn:
				intend_end_turn = false
				change_state(State.END_TURN)
		_:
			pass


func _enter_state(p_state: State) -> void:
	match p_state:
		State.START_GAME:
			print("Entering START_GAME state")
			model.reset_model()
			view.setup_cells(model.width, model.height)
			change_state(State.START_TURN)	
		State.START_TURN:
			print("Entering START_TURN state")
			await _start_turn()
			change_state(State.TURN)
		State.TURN:
			print("Entering TURN state")
		State.END_TURN:
			print("Entering END_TURN state")
			await _end_turn()
			change_state(State.START_TURN)
		_:
			print("Entering NULL or unknown state")


func _exit_state(p_state: State) -> void:
	match p_state:
		State.START_GAME:
			print("Exiting START_GAME state")
		State.START_TURN:
			print("Exiting START_TURN state")
		State.TURN:
			print("Exiting TURN state")
		State.END_TURN:
			print("Exiting END_TURN state")
		_:
			print("Exiting NULL or unknown state")


func _start_turn() -> void:
	print("--- starting turn ---")
	for key in model.cell_entity_map.keys():
		var entity: CellEntity = model.cell_entity_map[key]
		if entity != null:
			entity.on_turn_start(key.x, key.y, self)
			await Timers.wait_for(0.1)


func _end_turn() -> void:
	print("--- ending turn ---")
	for key in model.irrigation_map.keys():
		var current_level: int = model.irrigation_map[key]
		if current_level > 0:
			increase_irrigation(key.x, key.y, -1)
			await Timers.wait_for(0.05)

	for key in model.cell_entity_map.keys():
		var entity: CellEntity = model.cell_entity_map[key]
		if entity != null:
			entity.on_turn_end(key.x, key.y, self)


func _on_grid_resized(new_width: int, new_height: int) -> void:
	view.setup_cells(new_width, new_height)	


func _on_irrigation_changed(x: int, y: int, level: int) -> void:
	view.on_irrigation_changed(x, y, level)


func _on_cell_entity_changed(x: int, y: int, entity) -> void:	
	view.on_cell_entity_changed(x, y, entity)


func _connect_model_signals() -> void:
	if _model_signals_connected:
		return
	if model == null:
		return
	model.grid_resized.connect(_on_grid_resized)
	_model_signals_connected = true


func _disconnect_model_signals() -> void:
	if model == null:
		_model_signals_connected = false
		return
	if model.grid_resized.is_connected(_on_grid_resized):
		model.grid_resized.disconnect(_on_grid_resized)
	_model_signals_connected = false

