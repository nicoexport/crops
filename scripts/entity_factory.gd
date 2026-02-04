func create_plant_tomato() -> CellEntity:
    var e = CellEntity.new()
    e.type = CellEntity.Type.CROP
    e.name = "Tomato"
    e.mesh = SphereMesh.new()
    e.mature_age = 4
    return e


func create_sprinkler() -> CellEntity:
    var e = CellEntity.new()
    e.type = CellEntity.Type.SPRINKLER
    e.name = "Sprinkler"
    e.mesh = TorusMesh.new()
    return