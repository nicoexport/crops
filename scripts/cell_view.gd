class_name CellView extends CSGBox3D


@export var x: int
@export var y: int


signal slot_interacted(x: int, y: int)


func interact() -> void:
	print("CellView at (", x, ",", y, ") interacted.")
	slot_interacted.emit(x, y)	


