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
func on_turn():
	if type == Type.CROP:
		grow()

	if type == Type.SPRINKLER:
		water()	

func is_mature() -> bool:
	return age >= mature_age

func grow():
	if type == Type.CROP and age < mature_age:	
		age += 1
		print("Crop has grown to age %d." % age)	
		
func water():
	print("Sprinkler is watering adjacent cells.")
