class_name CellView extends CSGBox3D


@export var x: int
@export var y: int


signal slot_interacted(x: int, y: int, interaction: BaseInteraction)


func interact(interaction: BaseInteraction) -> void:
	slot_interacted.emit(x, y, interaction)	


