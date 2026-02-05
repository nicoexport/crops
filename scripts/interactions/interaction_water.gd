class_name InteractionWater extends BaseInteraction

var _amount: int


func _init(amount: int) -> void:
	_amount = amount


func perform(x: int, y: int, controller: GameController) -> void:
	controller.increase_irrigation(x, y, _amount)
