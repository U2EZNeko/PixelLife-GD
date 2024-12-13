extends Node2D
class_name Cell

@export var hp = 100
@export var stamina = 150
@export var hunger = 120
@export var speed = 1

func move(food_cells):
	# Find nearest food and move towards it
	var nearest_food = find_nearest_food(food_cells)
	if nearest_food:
		move_towards(nearest_food.position)

func move_towards(target_position):
	var direction = (target_position - position).normalized()
	position += direction * speed

func update_status():
	hunger -= 1
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
