class_name InteractionPrintCoords extends BaseInteraction


func perform(x: int, y: int, _controller: GameController) -> void:
	print("Performed print action at: ", str(x), " : ", str(y))
