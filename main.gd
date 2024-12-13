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
	update_simulation()
	render_simulation()

# Resets the simulation
func reset_simulation():
	var cell_container = $CellContainer
	var food_container = $FoodContainer

	if cell_container == null or food_container == null:
		push_error("Error: 'CellContainer' or 'FoodContainer' is missing in the scene tree.")
		return
	cells.clear()
	food_cells.clear()

	for index in range(NUM_INITIAL_CELLS):
		var cell = cell_object.instantiate()
		cell_container.add_child(cell)
		cell.position = Vector2(randi_range(0, SCREEN_WIDTH), randi_range(0, SCREEN_HEIGHT))
		cells.append(cell)

	for index in range(NUM_INITIAL_FOOD):
		var food = food_object.instantiate()
		food_container.add_child(food)
		food.position = Vector2(randi_range(0, SCREEN_WIDTH), randi_range(0, SCREEN_HEIGHT))
		food_cells.append(food)

# Updates the simulation
func update_simulation():
	for cell in cells:
		cell.move(food_cells)
		cell.update_status()
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
				print("Mating successful between cells at", cell.position, "and", other_cell.position)

# Render the cells and food
func render_simulation():
	pass
	#update()  # Triggers the `_draw` method
	# probably looking for queue_redraw() ^ 

func _draw():
	# Draw cells
	for cell in cells:
		draw_rect(Rect2(cell.position, Vector2(CELL_SIZE, CELL_SIZE)), Color(1, 1, 1))
	# Draw food
	for food in food_cells:
		draw_rect(Rect2(food.position, Vector2(CELL_SIZE, CELL_SIZE)), Color(0, 1, 0))

# Spawn a new food item
func spawn_food():
	var food_container = $FoodContainer

	if food_container == null:
		push_error("Error: 'FoodContainer' is missing in the scene tree.")
		return

# Handle interaction between cells and food
func handle_cell_food_interaction(cell):
	for food in food_cells:
		if cell.position.distance_to(food.position) < CELL_SIZE:
			cell.eat(food)
			food.queue_free()
			food_cells.erase(food)
			break
