extends Node2D

@export_category("Objects")
@export var cell_object: PackedScene
@export var food_object: PackedScene

# Constants
const SCREEN_WIDTH = 1400
const SCREEN_HEIGHT = 900
const CELL_SIZE = 5
const TICK_RATE = 30
const NUM_INITIAL_CELLS = 20
const NUM_INITIAL_FOOD = 100

var cells = []
var food_cells = []

func _ready():
	reset_simulation()

func _process(delta):
	update_simulation(delta)
	render_simulation()

# Resets the simulation
func reset_simulation():
	if cell_object == null:
		push_error("Error: 'cell_object' is not assigned in the inspector.")
		return
	if food_object == null:
		push_error("Error: 'food_object' is not assigned in the inspector.")
		return

	cells.clear()
	food_cells.clear()

	for index in range(NUM_INITIAL_CELLS):
		# Create the cell
		var cell = cell_object.instantiate()
		add_child(cell)

		# Set cell position
		cell.position = Vector2(randi_range(0, SCREEN_WIDTH), randi_range(0, SCREEN_HEIGHT))

		# Add to internal list
		cells.append(cell)

	for index in range(NUM_INITIAL_FOOD):
		spawn_food()

# Updates the simulation
func update_simulation(delta):
	for cell in cells:
		cell.move(food_cells)
		cell.update_status(delta)
		handle_cell_food_interaction(cell)
		handle_cell_mating(cell)
	# Respawn food
	while len(food_cells) < NUM_INITIAL_FOOD:
		spawn_food()

# Handle interaction between cells for mating
func handle_cell_mating(cell):
	for other_cell in cells:
		if cell != other_cell and cell.position.distance_to(other_cell.position) <= cell.mating_distance_threshold:
			if cell.mate(other_cell):
				# New cells are already added in the `mate` function
				prints("Mating successful between cells at", cell.position, "and", other_cell.position)

# FIXME: This is all redundant. The cells and food objects can handle drawing themselves. Even better- they can just be sprites instead of doing it via code.
# Render the cells and food
func render_simulation():
	pass
	#update()  # Triggers the `_draw` method
	# probably looking for queue_redraw() ^ 

#func _draw():
	## Draw cells
	#for cell in cells:
		#draw_rect(Rect2(cell.position, Vector2(CELL_SIZE, CELL_SIZE)), Color(1, 1, 1))
	## Draw food
	#for food in food_cells:
		#draw_rect(Rect2(food.position, Vector2(CELL_SIZE, CELL_SIZE)), Color(0, 1, 0))

func spawn_food():
	# Create the food
	var food = food_object.instantiate()
	add_child(food)

	# Set food position
	food.position = Vector2(randi_range(0, SCREEN_WIDTH), randi_range(0, SCREEN_HEIGHT))

	# Add to internal list
	food_cells.append(food)

# Handle interaction between cells and food
func handle_cell_food_interaction(cell):
	for food in food_cells:
		if cell.position.distance_to(food.position) < CELL_SIZE:
			cell.eat(food)
			food.queue_free()
			food_cells.erase(food)
			break
