@tool
class_name GameView extends Node3D

@export_group("Visuals")
@export var cell_material: Material
@export var spacing: Vector2:
	set(v):
		spacing = v
		setup_cells(grid_width, grid_height)	

@export var controller: GameController:
	set(c):
		controller = c

@export var cell_parent_node: Node3D

var grid_width: int = 0
var grid_height: int = 0
var cell_views := {}


func _ready() -> void:
	controller.change_state(GameController.State.START_GAME)


func set_end_turn_intent() -> void:
	controller.intend_end_turn = true


func setup_cells(new_width: int, new_height: int) -> void:
	if !is_inside_tree():
		return
		
	# Clear existing grid view
	cell_views.clear()
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
		
	grid_width = new_width
	grid_height = new_height
	var centering_offset: Vector2 = 0.5 * (Vector2.ONE + spacing) * Vector2(grid_width - 1, grid_height - 1)
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
			cell_views[Vector2i(x, y)] = cell_view
			if Engine.is_editor_hint() and scene_owner != null:
				cell_view.owner = scene_owner


func on_irrigation_changed(x: int, y: int, level: int):
	var box = cell_views.get(Vector2i(x, y))
	if box != null:
		(box.material as ShaderMaterial).set_shader_parameter("irrigation_level", level)


func on_cell_entity_changed(x: int, y: int, entity: CellEntity) -> void:
	var box = cell_views.get(Vector2i(x, y))
	if box != null:
		# remove old entity model if any
		for child in box.get_children():
			child.queue_free()

		if entity != null and entity.model != null:
			var entity_instance = MeshInstance3D.new()
			entity_instance.mesh = entity.model
			box.add_child(entity_instance)


func _on_slot_interacted(x: int, y: int, interaction: BaseInteraction) -> void:
	controller.perform_interaction_on_model(x, y, interaction)