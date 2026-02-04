class_name CellEntity

enum Type {NULL, CROP, SPRINKLER}

# data 
var type: Type
var name: String
var model: Mesh
var mature_age: int

# state 
var age: int = 0