extends Node3D

@export var player: Node3D

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB

var health := 100
var time := 0.0
#var target_position: Vector3
var destroyed := false

# When ready, save the initial position

#func _ready():
	#target_position = position


func _process(delta):
	self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)  # Look at player
	#target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)
	var new_position = position
	new_position = new_position.move_toward(player.position, 0.04)

	time += delta

	position = new_position

# Take damage from player

func clone_self_random_position():
	# Создаем копию текущего объекта
	var cloned_object = self.duplicate()  # Копируем текущий узел
	
	# Устанавливаем случайную позицию для клона в 3D
	cloned_object.position = get_random_position()
	
	# Добавляем клон в родительский узел
	get_parent().add_child(cloned_object)

# Функция для генерации случайной позиции в 3D
func get_random_position() -> Vector3:
	var random_x = randf_range(-50, 50)  # Произвольная координата X
	var random_y = randf_range(0, 50)    # Произвольная координата Y (например, высота)
	var random_z = randf_range(-50, 50)  # Произвольная координата Z
	return Vector3(random_x, random_y, random_z)

func damage(amount):
	clone_self_random_position()
	
	Audio.play("sounds/enemy_hurt.ogg")

	health -= amount

	if health <= 0 and !destroyed:
		destroy()

# Destroy the enemy when out of health

func destroy():
	Audio.play("sounds/enemy_destroy.ogg")

	destroyed = true
	queue_free()

# Shoot when timer hits 0

func _on_timer_timeout():
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var collider = raycast.get_collider()

		if collider.has_method("damage"):  # Raycast collides with player
			
			# Play muzzle flash animation(s)

			muzzle_a.frame = 0
			muzzle_a.play("default")
			muzzle_a.rotation_degrees.z = randf_range(-45, 45)

			muzzle_b.frame = 0
			muzzle_b.play("default")
			muzzle_b.rotation_degrees.z = randf_range(-45, 45)

			Audio.play("sounds/enemy_attack.ogg")

			collider.damage(5)  # Apply damage to player
