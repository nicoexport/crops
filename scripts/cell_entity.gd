class_name CellEntity

enum Type {NULL, CROP, SPRINKLER}

# data 
var type: Type
var name: String
var model: Mesh
var mature_age: int

# state 
var age: int = 0

# behavior
func on_turn_start(x: int, y: int, model: GameModel) -> void:
	if type == Type.SPRINKLER:
		water(x, y, model)	


func on_turn_end(x: int, y: int, model: GameModel) -> void:
	if type == Type.CROP:
		grow()
	

func is_mature() -> bool:
	return age >= mature_age

func grow():
	if type == Type.CROP and age < mature_age:	
		age += 1
		print("Crop has grown to age %d." % age)	

func water(x: int, y: int, model: GameModel) -> void:
	print("Sprinkler is watering adjacent cells.")
	# Implementation for watering adjacent cells would go here
	model.add_irrigation_to_area(x, y, 1)
		
