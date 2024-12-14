extends Node

@export_category("Simulation Parameters")
@export_range (2, 50) var initial_cells: int = 20
@export_range (1, 100) var initial_food: int = 100

@export_category("Objects")
@export var cell_object: PackedScene
@export var food_object: PackedScene

# Constants
#const CELL_SIZE = 5
#const TICK_RATE = 30
#const NUM_INITIAL_CELLS = 20
#const NUM_INITIAL_FOOD = 100

## INFO:
## instead of creating the two arrays and the two "containers" for the food and cells at runtime, 
## you can just do so in the engine by adding two Node2Ds, and there would be no need for the arrays.
## you can get a reference to the nodes by setting them as 'Unique Name', and use %<Node Name> to grab it, 
## when the scene is ready.
##
@export_category("References")
@onready var cell_group: Node2D = %Cells
@onready var food_group: Node2D = %Food
#var cells = []
#var food_cells = []
@onready var screen_size = get_viewport().get_visible_rect().size

# start simulation
func _ready() -> void:
	_reset_simulation()

func _physics_process(_delta: float) -> void:
	# update cell physics
	for cell in cell_group.get_children():
		cell.move(food_group.get_children())

		## INFO: these were replaced with collision events on the object level.
		#_handle_cell_food_interaction(cell)
		#_handle_cell_mating(cell)

func _process(delta: float) -> void:
	# update cells
	for cell in cell_group.get_children():
		cell.update(delta)

	# respawn food cells when the amount gets low
	if food_group.get_child_count() < initial_food:
		for missing_food in initial_food - food_group.get_child_count():
			_spawn_food()

# restarts the simulation
func _reset_simulation() -> void:
	# 'kill' all the cell and food nodes
	for cell in cell_group.get_children():
		cell.queue_free()
	for food in food_group.get_children():
		food.queue_free()

	# spawn new cells and food by the defined initial amount
	for _cell in initial_cells:
		_spawn_cell()
	for _food in initial_food:
		_spawn_food()

	#var cell_container = $CellContainer
	#var food_container = $FoodContainer

	## INFO: no need for error handling here. the container should always exist, as its added in-editor and not at runtime.
	#if cell_container == null or food_container == null:
		#push_error("Error: 'CellContainer' or 'FoodContainer' is missing in the scene tree.")
		#return
	#cells.clear()
	#food_cells.clear()

	#for index in range(NUM_INITIAL_CELLS):
		#var cell = cell_object.instantiate()
		#cell_container.add_child(cell)
		#cell.position = Vector2(randi_range(0, SCREEN_WIDTH), randi_range(0, SCREEN_HEIGHT))
		#cells.append(cell)

	#for index in range(NUM_INITIAL_FOOD):
		#var food = food_object.instantiate()
		#food_container.add_child(food)
		#food.position = Vector2(randi_range(0, SCREEN_WIDTH), randi_range(0, SCREEN_HEIGHT))
		#food_cells.append(food)

## INFO: using an engine means u dont really have to handle rendering it at all.
# Render the cells and food
#func render_simulation():
	#pass
	#update()  # Triggers the `_draw` method
	# probably looking for queue_redraw() ^ 

#func _draw():
	## Draw cells
	#for cell in cells:
		#draw_rect(Rect2(cell.position, Vector2(CELL_SIZE, CELL_SIZE)), Color(1, 1, 1))
	## Draw food
	#for food in food_cells:
		#draw_rect(Rect2(food.position, Vector2(CELL_SIZE, CELL_SIZE)), Color(0, 1, 0))

# spawn new cell node
func _spawn_cell() -> void:
	# use the provided cell object and 'clone' it by instantiating it in this scene
	var cell: Cell = cell_object.instantiate()
	cell_group.add_child(cell)

	# set its position
	cell.position = Vector2(randi_range(0, screen_size.x), randi_range(0, screen_size.y))

# spawn new food node
func _spawn_food() -> void:
	# use the provided food object and 'clone' it by instantiating it in this scene
	var food: Food = food_object.instantiate()
	food_group.add_child(food)

	# set its position
	food.position = Vector2(randi_range(0, screen_size.x), randi_range(0, screen_size.y))

	#var food_container = $FoodContainer
#
	#if food_container == null:
		#push_error("Error: 'FoodContainer' is missing in the scene tree.")
		#return
