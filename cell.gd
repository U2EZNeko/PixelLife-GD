extends Node2D
class_name Cell

@export var hp = 100
@export var stamina = 150
@export var hunger = 120
@export var speed = 1
@export var mating_cooldown_time = 5.0  # Cooldown in seconds
@export var mating_cost_stamina = 50
@export var mating_cost_hunger = 30
@export var mating_distance_threshold = 5.0  # Distance threshold for mating

var last_mating_time = -mating_cooldown_time  # Initialize to allow immediate mating after start

var size: int = 15  # Size of the cell in pixels

func _draw():
	# Draw a simple green square to represent the food
	draw_rect(Rect2(Vector2(0, 0), Vector2(size, size)), Color(1, 1, 1))

func move(food_cells):
	# Find nearest food and move towards it
	var nearest_food = find_nearest_food(food_cells)
	if nearest_food:
		move_towards(nearest_food.position)

func move_towards(target_position):
	var direction = (target_position - position).normalized()
	position += direction * speed

func update_status(delta):
	hunger -= 1 * delta
	if hunger <= 0:
		hp -= 1
	elif hunger >= 90:
		hp += 1

func eat(_food):
	hunger += 25
	stamina += 15

func find_nearest_food(food_cells):
	var nearest_food = null
	var min_distance = INF
	for food in food_cells:
		var distance = position.distance_to(food.position)
		if distance < min_distance:
			min_distance = distance
			nearest_food = food
	return nearest_food

func can_mate(partner):
	return stamina >= mating_cost_stamina and hunger >= mating_cost_hunger and (Time.get_ticks_msec() / 1000.0 - last_mating_time >= mating_cooldown_time) and position.distance_to(partner.position) <= mating_distance_threshold

func mate(partner):
	if not can_mate(partner):
		return false

	# Ensure both cells agree to mate
	if partner.can_mate(self):
		# Reduce energy costs for both cells
		stamina -= mating_cost_stamina
		hunger -= mating_cost_hunger

		partner.stamina -= mating_cost_stamina
		partner.hunger -= mating_cost_hunger

		# Reset cooldown timer
		last_mating_time = Time.get_ticks_msec() / 1000.0
		partner.last_mating_time = last_mating_time

		# Trigger new cell creation (logic to add to the game world)
		create_offspring(partner)
		return true

	return false

func create_offspring(partner):
	# Spawn 1-4 new cells
	var offspring_count = randi() % 4 + 1  # Random number between 1 and 4

	for i in range(offspring_count):
		var new_cell = Cell.new()
		new_cell.position = (position + partner.position) / 2 + Vector2(randi() % 10 - 5, randi() % 10 - 5)  # Randomize spawn position slightly
		new_cell.hp = (hp + partner.hp) / 2
		new_cell.stamina = (stamina + partner.stamina) / 2
		new_cell.hunger = (hunger + partner.hunger) / 2
		new_cell.speed = (speed + partner.speed) / 2

		# Add new cell to the scene tree
		get_parent().add_child(new_cell)
		prints("New cell created at", new_cell.position)
		prints("New cell created with HP:", new_cell.hp, "Stam:", new_cell.stamina, "Speed:", new_cell.speed)
