class_name InteractionPlaceEntity extends BaseInteraction


var _entity_create_func: Callable 


func perform(x: int, y: int, controller: GameController) -> void:
	var entity = _entity_create_func.call()
	if entity == null:
		printerr("InteractionPlaceEntity: Entity creation function returned null!")
		return
	controller.try_place_entity_on_map(x, y, entity)	


func _init(entity_create_func: Callable) -> void:
	_entity_create_func = entity_create_func	
