class_name InteractionChangeValue extends BaseInteraction


func perform(x: int, y: int, model: GameModel):
    var current_value = model.cells.get(Vector2i(x, y), 0)
    var new_value = 1 if current_value == 0 else 0
    model.set_cell(x, y, new_value)