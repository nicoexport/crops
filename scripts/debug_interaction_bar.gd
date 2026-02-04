extends HBoxContainer

@export var interactor: Interactor
@export_category("Buttons")
@export var coords: Button
@export var water: Button
@export var plant: Button
@export var sprinker: Button
@export var remove: Button

func _ready() -> void:	
	coords.pressed.connect(handle_coords_pressed)
	water.pressed.connect(handle_water_pressed)
	plant.pressed.connect(handle_plant_pressed)
	sprinker.pressed.connect(handle_sprinkler_pressed)
	remove.pressed.connect(handle_remove_pressed)

	coords.button_pressed = true
	handle_coords_pressed()


func handle_coords_pressed():
	interactor.selected_interaction = InteractionPrintCoords.new()


func handle_water_pressed():
	interactor.selected_interaction = InteractionWater.new(1)


func handle_plant_pressed():
	interactor.selected_interaction = InteractionPlaceEntity.new(EntityFactory.create_plant_tomato)	


func handle_sprinkler_pressed():
	interactor.selected_interaction = InteractionPlaceEntity.new(EntityFactory.create_sprinkler)


func handle_remove_pressed():
	interactor.selected_interaction = InteractionRemoveEntity.new()