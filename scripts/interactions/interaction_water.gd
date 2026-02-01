class_name InteractionWater extends BaseInteraction


var _amount


func _init(amount: int) -> void:
    _amount = amount


func perform(x: int, y: int, model: GameModel):
    model.add_irrigation_level(x, y, _amount)