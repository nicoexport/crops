class_name InteractionRemoveEntity extends BaseInteraction


func perform(x: int, y: int, model: GameModel):	
	model.try_remove_entity_from_map(x, y)