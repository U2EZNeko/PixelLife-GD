extends Node2D
class_name Cell

# constants
const mating_cost_stamina: float = 50.
const mating_cost_satiation: float = 30.

@export_category("Properties")
@export var hp: float = 100.
@export var stamina: float = 150.
@export var satiation: float = 120.
@export var speed: float = 1.
#@export var mating_cooldown_time := 5.0  # Cooldown in seconds
#@export var mating_distance_threshold := 5.0  # Distance threshold for mating

@export_category("References")
@onready var mating_cooldown: Timer = %"Mating Cooldown"

# internal
#var last_mating_time := -mating_cooldown_time  # Initialize to allow immediate mating after start

#var size: int = 15  # Size of the cell in pixels

#func _draw():
	## Draw a simple green square to represent the food
	#draw_rect(Rect2(Vector2(0, 0), Vector2(size, size)), Color(1, 1, 1))

# called by scene parent
func move(food_nodes: Array[Node]) -> void:
	# Find nearest food and move towards it
	var nearest_food = _find_nearest_food(food_nodes)
	if nearest_food is Food:
		_move_towards(nearest_food.position)

# called by scene parent
func update(delta: float) -> void:
	# update satiation
	satiation -= delta * 35

	# lose HP if hungry
	if satiation <= 0:
		hp -= 1

	# gain HP if full
	elif satiation >= 90:
		hp += 1

	# die if low
	if hp <= 0:
		queue_free()

func _move_towards(target_position: Vector2) -> void:
	var direction = (target_position - position).normalized()
	position += direction * speed

func _find_nearest_food(food_nodes: Array[Node]) -> Food:
	var nearest_food: Food
	var min_distance

	# look through all food nodes
	for food in food_nodes:
		# skip non-food nodes
		if food is not Food:
			continue

		# check food distance to this cell
		var distance = position.distance_to(food.position)
		if nearest_food is not Food or distance < min_distance:
			# save as nearest
			min_distance = distance
			nearest_food = food

	return nearest_food

func _eat(food: Food) -> void:
	# consume food
	food.consume()

	satiation += 25
	stamina += 15

func _mate(partner: Cell) -> bool:
	# cannot mate yet
	if not can_mate():
		return false

	# Ensure both cells agree to mate
	if partner.can_mate():
		# Reduce energy costs for both cells
		stamina -= mating_cost_stamina
		satiation -= mating_cost_satiation

		partner.stamina -= mating_cost_stamina
		partner.satiation -= mating_cost_satiation

		# Reset cooldown timer
		#last_mating_time = Time.get_ticks_msec() / 1000.0
		mating_cooldown.start()
		partner.mating_cooldown.start()

		# Trigger new cell creation (logic to add to the game world)
		_create_offspring(partner)
		return true

	return false

func can_mate() -> bool:
	return stamina >= mating_cost_stamina and satiation >= mating_cost_satiation and mating_cooldown.is_stopped()

func _create_offspring(partner: Cell) -> void:
	# Spawn 1-4 new cells
	var offspring_count = randi_range(1, 4)  # Random number between 1 and 4

	# spawn each offspring
	for _index in offspring_count:
		var new_cell = self.duplicate()
		#var new_cell = Cell.new()
		new_cell.position = (position + partner.position) / 2. + Vector2(randi_range(5, 10), randi_range(5, 10))  # Randomize spawn position slightly
		new_cell.hp = (hp + partner.hp) / 2.
		new_cell.stamina = (stamina + partner.stamina) / 2.
		new_cell.satiation = (satiation + partner.satiation) / 2.
		new_cell.speed = (speed + partner.speed) / 2.

		# Add new cell to the scene tree
		get_parent().call_deferred("add_child", new_cell)
		## INFO: i know these are for debug
		#prints("New cell created at", new_cell.position)
		#prints("New cell created with HP:", new_cell.hp, "Stam:", new_cell.stamina, "Speed:", new_cell.speed)

func _on_collision_detected(area: Area2D) -> void:
	# get parent node of collided area node
	var node = area.get_parent()

	# eat food
	if node is Food:
		_eat(node)

	# mate with other cell
	elif node is Cell:
		_mate(node)
