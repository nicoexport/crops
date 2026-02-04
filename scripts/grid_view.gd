@tool
class_name GridView extends Node3D

@export_tool_button("Rebuild Grid", "Callable") var rebuild_action = _rebuild_from_model

@export_group("Visuals")
@export var cell_material: Material
@export var spacing: Vector2:
	set(v):
		spacing = v
		_rebuild_from_model()

@export_group("References")
@export var model: GameModel:
	set(m):
		_disconnect_model_signals()
		model = m
		_connect_model_signals()
		_rebuild_from_model()

@export var cell_parent_node: Node3D


var _connected: bool = false


func _ready() -> void:
	_connect_model_signals()
	_rebuild_from_model()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == Key.KEY_T:
				if model != null:
					model.process_turn()			


func setup_grid_sockets(new_width: int, new_height: int) -> void:
	if !is_inside_tree():
		return
		
	# Clear existing grid view
	for n in cell_parent_node.get_children():
		if n is CSGBox3D:
			n.free()


	var tree := get_tree()	
	if tree == null:
		return

	var scene_owner := get_tree().edited_scene_root
	# Fallback if not available for some reason
	if scene_owner == null:
		scene_owner = owner
		

	var centering_offset: Vector2 = 0.5 * (Vector2.ONE + spacing) * Vector2(model.width - 1, model.height - 1)

	# Create new grid view based on model dimensions
	for x in range(new_width):
		for y in range(new_height):
			var cell_view = CellView.new()
			cell_view.x = x
			cell_view.y = y
			# Assuming a predefined mesh for grid cells
			var position_2d = Vector2(x, y) * Vector2(1 + spacing.x, 1 + spacing.y) - centering_offset
			cell_view.position = Vector3(position_2d.x, 0, position_2d.y)
			cell_view.use_collision = true	
			cell_view.material = cell_material.duplicate(true)
			cell_view.size.y = 0.1
			cell_view.slot_interacted.connect(_on_slot_interacted)
			cell_parent_node.add_child(cell_view)	
			if Engine.is_editor_hint() and scene_owner != null:
				cell_view.owner = scene_owner

	for x in range (new_width):
		for y in range (new_height):
			if model != null:
				model.set_cell(x, y, randi_range(0, 1))  # Initialize cells to default value	


func _connect_model_signals() -> void:
	if _connected: 
		return
	
	if model == null:
		return

	if not model.grid_resized.is_connected(_on_model_grid_resized):
		model.grid_resized.connect(_on_model_grid_resized)

	if not model.cell_changed.is_connected(_on_cell_changed):
		model.cell_changed.connect(_on_cell_changed)

	if not model.irrigation_changed.is_connected(_on_irrigation_changed):
		model.irrigation_changed.connect(_on_irrigation_changed)

	if not model.cell_entity_changed.is_connected(_on_cell_entity_changed):
		model.cell_entity_changed.connect(_on_cell_entity_changed)

	_connected = true


func _disconnect_model_signals() -> void:
	if model == null:
		_connected = false
		return

	if model.grid_resized.is_connected(_on_model_grid_resized):
		model.grid_resized.disconnect(_on_model_grid_resized)

	if model.cell_changed.is_connected(_on_cell_changed):
		model.cell_changed.disconnect(_on_cell_changed)

	_connected = false


func _rebuild_from_model() -> void:
	if model == null:
		return
	setup_grid_sockets(model.width, model.height)


func _on_model_grid_resized(new_width: int, new_height: int) -> void:
	setup_grid_sockets(new_width, new_height)	


func _on_cell_changed(x: int, y: int, value: int) -> void:
	# Update the specific cell in the grid view based on model change
	var index = y + x * model.height
	var box = cell_parent_node.get_child(index) as CSGBox3D
	if box != null:
		# Update the cell appearance based on the value
		# This is a placeholder; actual implementation may vary
		return


func _on_irrigation_changed(x: int, y: int, level: int):
	var index = y + x * model.height
	var box = cell_parent_node.get_child(index) as CSGBox3D
	if box != null:
		(box.material as ShaderMaterial).set_shader_parameter("irrigation_level", level)


func _on_cell_entity_changed(x: int, y: int, entity: CellEntity) -> void:
	var index = y + x * model.height
	var box = cell_parent_node.get_child(index) as CSGBox3D
	if box != null:
		# remove old entity model if any
		for child in box.get_children():
			child.queue_free()

		if entity != null and entity.model != null:
			var entity_instance = MeshInstance3D.new()
			entity_instance.mesh = entity.model
			box.add_child(entity_instance)


func _on_slot_interacted(x: int, y: int, interaction: BaseInteraction) -> void:
	if model != null:
		interaction.perform(x, y, model)
		return 
