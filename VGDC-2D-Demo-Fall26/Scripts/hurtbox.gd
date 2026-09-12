class_name Hurtbox extends Area2D

# External Variables
@export var hostile: bool

func _ready() -> void:
	#Sets the Area to only be monitorable
	monitoring = false
	
	#Removes the initial collision layer values
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	#Sets the appropriate values based on hostility
	if hostile:
		set_collision_layer_value(5, true) #Enemy hitbox layer
	else:
		set_collision_layer_value(3, true) # Player #hitbox layer

func _recieve_hit(_damage: float, _knockback: float, _direction: Vector2):
	# Check if the damage is not zero and if the owner isnt dead
	if _damage > 0 and owner.health > 0:
		owner.health -= _damage
		
		# Flashing red when hit | can remove if you'd like
		owner.modulate = "ff0000"
		await get_tree().create_timer(0.1).timeout
		owner.modulate = "ffffff"
		
		# Knockback
		owner.velocity = _direction * _knockback
		
		#*************************************************#
		# Only write healthbar code after the Hit/Hurtboxes
		
		#owner._update_healthbar()
