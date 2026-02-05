class_name CellEntity


enum Type {NULL, CROP, SPRINKLER}

# --- data --- 
var type: Type
var name: String
var model: Mesh
var mature_age: int

# --- state --- 
var age: int = 0

# --- behavior --- 
func on_turn_start(x: int, y: int, controller: GameController) -> void:
	if type == Type.SPRINKLER:
		water(x, y, controller)
		return  # Simulate time taken to water


func on_turn_end(_x: int, _y: int, _controller: GameController) -> void:
	if type == Type.CROP:
		grow()
	

func is_mature() -> bool:
	return age >= mature_age


func grow():
	if type == Type.CROP and age < mature_age:	
		age += 1
		print("Crop has grown to age %d." % age)	

func water(x: int, y: int, controller: GameController) -> void:
	print("Sprinkler is watering adjacent cells.")
	# Implementation for watering adjacent cells would go here
	controller.increase_irrigation_in_area(x, y, 1)
		
