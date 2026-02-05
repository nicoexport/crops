class_name CellView extends CSGBox3D


signal slot_interacted(x: int, y: int, interaction: BaseInteraction)

@export var x: int
@export var y: int


func interact(interaction: BaseInteraction) -> void:
	slot_interacted.emit(x, y, interaction)	

