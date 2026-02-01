extends Node3D


var highlight_box: CSGBox3D
var interaction_intended: bool = false	
var selected_interaction: BaseInteraction = null


func _ready() -> void:
	highlight_box = CSGBox3D.new()
	highlight_box.size = Vector3(1.1, 0.1, 1.1)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 1, 1, 0.5)
	highlight_box.material = mat
	add_child(highlight_box)
	highlight_box.visible = false	

	selected_interaction = InteractionPrintCoords.new()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				interaction_intended = true

	if event.is_action_pressed("2"):
		selected_interaction = InteractionWater.new(1)

	if event.is_action_pressed("1"):
		selected_interaction = InteractionPrintCoords.new()


func _physics_process(_delta: float) -> void:	
	shoot_ray_from_mouse()


func shoot_ray_from_mouse():
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	var mouse_pos := get_viewport().get_mouse_position()

	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_direction := camera.project_ray_normal(mouse_pos)
	var ray_length := 1000.0

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + ray_direction * ray_length
	)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(query)

	if result:
		highlight_box.visible = true
		var pos: Vector3 = result.collider.global_position
		highlight_box.position = pos + Vector3(0, 0.4, 0)
		
		if interaction_intended:
			if result.collider is CellView:
				var cell_view: CellView = result.collider
				cell_view.interact(selected_interaction)
				
	else:
		highlight_box.visible = false

	interaction_intended = false
