extends Node2D

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
	for: cells in range(NUM_INITIAL_CELLS):
		cell.position = Vector2(rand_range(0, SCREEN_WIDTH), rand_range(0, SCREEN_HEIGHT))
		$CellContainer.add_child(cell)
		cells.append(cell)
	for: food in range(NUM_INITIAL_FOOD):
		food.position = Vector2(rand_range(0, SCREEN_WIDTH), rand_range(0, SCREEN_HEIGHT))
		$FoodContainer.add_child(food)
		food_cells.append(food)


# Updates the simulation
func update_simulation():
	for cell in cells:
		cell.move(food_cells)
		cell.update_status()
		handle_cell_food_interaction(cell)
	# Respawn food
	while len(food_cells) < NUM_INITIAL_FOOD:
		spawn_food()

# Render the cells and food
func render_simulation():
	update()  # Triggers the `_draw` method

func _draw():
	# Draw cells
	for cell in cells:
		draw_rect(Rect2(cell.position, Vector2(CELL_SIZE, CELL_SIZE)), Color(1, 1, 1))
	# Draw food
	for food in food_cells:
		draw_rect(Rect2(food.position, Vector2(CELL_SIZE, CELL_SIZE)), Color(0, 1, 0))

# Spawn a new food item
func spawn_food():
	var food = preload("res://Food.tscn").instance()
	food.position = Vector2(randi() % SCREEN_WIDTH, randi() % SCREEN_HEIGHT)
	add_child(food)
	food_cells.append(food)

# Handle interaction between cells and food
func handle_cell_food_interaction(cell):
	for food in food_cells:
		if cell.position.distance_to(food.position) < CELL_SIZE:
			cell.eat(food)
			food.queue_free()
			food_cells.erase(food)
			break
