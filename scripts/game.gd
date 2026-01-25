@tool
extends Node3D


@export var socket_container: Node3D	
@export var socket_mesh: Mesh	

var grid = []

@export var grid_width = 5:
	get:
		return grid_width
	set(value):
		print(grid_width)
		if value != grid_width:
			grid_width = value	
			grid.resize(value)
			setup_grid_sockets()
		
@export var grid_height = 5:
	get:
		return grid_height
	set(value):
		print(grid_height)	
		if value != grid_height:
			grid_height = value	
			for x in range(grid_width):
				grid[x].resize(value)
			setup_grid_sockets()	


func _ready() -> void:
	for x in range(grid_width):
		grid.append([])
		for y in range(grid_height):
			grid[x].append(0)

	setup_grid_sockets()


func setup_grid_sockets() -> void:
	for n in socket_container.get_children():
		if n is MeshInstance3D:
			n.queue_free()
			
	for x in range(grid_width):
		for y in range(grid_height):
			var instance = MeshInstance3D.new()
			instance.mesh = socket_mesh
			instance.position = Vector3(x * 2, 0, y * 2)
			socket_container.add_child(instance)
