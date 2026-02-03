extends HBoxContainer

@export var interactor: Interactor
@export_category("Buttons")
@export var coords: Button
@export var water: Button


func _ready() -> void:	
	coords.pressed.connect(handle_coords_pressed)
	water.pressed.connect(handle_water_pressed)
	
	coords.button_pressed = true
	handle_coords_pressed()


func handle_coords_pressed():
	interactor.selected_interaction = InteractionPrintCoords.new()


func handle_water_pressed():
	interactor.selected_interaction = InteractionWater.new(1)