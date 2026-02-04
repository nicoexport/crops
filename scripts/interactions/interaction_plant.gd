class_name InteractionPlant extends BaseInteraction


func perform(x: int, y: int, model: GameModel):
	print("performed plant action at: ", str(x), " : ", str(y))
	var plant = EntityFactory.create_plant_tomato()
	model.try_place_entity_on_map(x, y, plant)	
