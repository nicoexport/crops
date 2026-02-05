class_name InteractionRemoveEntity extends BaseInteraction


func perform(x: int, y: int, controller: GameController) -> void:	
	controller.try_remove_entity_from_map(x, y)