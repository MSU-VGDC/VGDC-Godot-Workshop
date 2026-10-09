class_name Hurtbox extends Area2D

# External Variables
@export var hostile: bool

func _ready() -> void:
	# seting the area2d tp be monitorable
	monitoring = false
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	# set collision
	if hostile:
		set_collision_layer_value(5, true)
	else:
		set_collision_layer_value(3, true)

func _recieve_hit(_damage: float, _knockback: float, _direction: Vector2):
	# Check if damage is not zero and if the owner is not dead
	if _damage > 0 and owner.health > 0:
		owner.health -= _damage
		
		# Flashing color when hit
		owner.find_child("AnimatedSprite2D").modulate = "ff0000"
		await get_tree().create_timer(0.1).timeout
		owner.find_child("AnimatedSprite2D").modulate = "ffffff"
		
		# Knockback
		owner.velocity = _direction * _knockback
		
		# Updating healthbar
		owner._update_healthbar()
