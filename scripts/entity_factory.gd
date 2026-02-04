extends Node 


func create_plant_tomato() -> CellEntity:
	var e = CellEntity.new()
	e.type = CellEntity.Type.CROP
	e.name = "Tomato"
	var mesh = SphereMesh.new()
	mesh.radius = 0.3
	e.model = mesh
	e.mature_age = 4
	return e


func create_sprinkler() -> CellEntity:
	var e = CellEntity.new()
	e.type = CellEntity.Type.SPRINKLER
	e.name = "Sprinkler"
	var mesh = TorusMesh.new()
	mesh.inner_radius = 0.1
	mesh.outer_radius = 0.3
	e.model = mesh
	return e
