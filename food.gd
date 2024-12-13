extends Node2D
class_name Food

# Signal emitted when the food is consumed
#signal consumed

var size: int = 5  # Size of the food in pixels

#func _ready():
	#update()  # Ensure the food is drawn

func _draw():
	# Draw a simple green square to represent the food
	draw_rect(Rect2(Vector2(0, 0), Vector2(size, size)), Color(0, 1, 0))

func consume():
	"""
	Called when a cell eats this food. Marks the food as consumed and emits a signal.
	"""
	emit_signal("consumed")
	queue_free()  # Remove this node from the scene tree
