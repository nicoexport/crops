@tool
class_name GameController extends Node

enum State {NULL, START_GAME, START_TURN, TURN, END_TURN}

@export var model: GameModel:
	set(m):
		_disconnect_model_signals()
		model = m
		_connect_model_signals()
@export var view: GameView:
	set(v):
		view = v


var intend_end_turn: bool = false

var _state: State = State.NULL	
var _model_signals_connected: bool = false	


func perform_interaction_on_model(x: int, y: int, interaction: BaseInteraction) -> void:
	interaction.perform(x, y, model)


func change_state(p_state: State) -> void:
	_exit_state(_state)
	_state = p_state
	_enter_state(_state)


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		_process_state(_state, delta)


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


func _process_state(p_state: State, _delta: float) -> void:
	match p_state:
		State.TURN:
			if intend_end_turn:
				intend_end_turn = false
				change_state(State.END_TURN)
		_:
			pass


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
			entity.on_turn_start(key.x, key.y, model)
			await Timers.wait_for(0.1)


func _end_turn() -> void:
	print("--- ending turn ---")
	for key in model.irrigation_map.keys():
		var current_level: int = model.irrigation_map[key]
		if current_level > 0:
			model.set_irrigation_level(key.x, key.y, current_level - 1)
			await Timers.wait_for(0.05)

	for key in model.cell_entity_map.keys():
		var entity: CellEntity = model.cell_entity_map[key]
		if entity != null:
			entity.on_turn_end(key.x, key.y, model)


func _connect_model_signals() -> void:
	if _model_signals_connected:
		return
	if model == null:
		return
	model.grid_resized.connect(_on_grid_resized)
	model.irrigation_changed.connect(_on_irrigation_changed)
	model.cell_entity_changed.connect(_on_cell_entity_changed)
	_model_signals_connected = true


func _disconnect_model_signals() -> void:
	if model == null:
		_model_signals_connected = false
		return
	if model.grid_resized.is_connected(_on_grid_resized):
		model.grid_resized.disconnect(_on_grid_resized)
	if model.irrigation_changed.is_connected(_on_irrigation_changed):
		model.irrigation_changed.disconnect(_on_irrigation_changed)
	if model.cell_entity_changed.is_connected(_on_cell_entity_changed):
		model.cell_entity_changed.disconnect(_on_cell_entity_changed)
	_model_signals_connected = false


func _on_grid_resized(new_width: int, new_height: int) -> void:
	view.setup_cells(new_width, new_height)	


func _on_irrigation_changed(x: int, y: int, level: int) -> void:
	view.on_irrigation_changed(x, y, level)


func _on_cell_entity_changed(x: int, y: int, entity) -> void:	
	view.on_cell_entity_changed(x, y, entity)
