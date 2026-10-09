extends CharacterBody2D

# Player Variable
var player: CharacterBody2D

# Movemenet Variables
@export var speed: float = 10
@export var max_health: float = 25
@export var acceleration: float = 16
@export var damage: float = 5
@export var cooldownTime: float = 1
@export var wanderTime: float = 5
@export var knockback: float = 32

# Node Variables
@export var Sprite: AnimatedSprite2D
@export var Cooldown: Timer

# Hitbox Variables
@export var HitboxSpawn: Node2D
@export var hitboxShape: Shape2D
@export var hitbox_distance: int = 32
@export var Healthbar: TextureProgressBar

# Internal Variables
const MOVEMENT_MULTIPLIER: float = 16
var health: float
var state: int
var direction: Vector2 = Vector2.ZERO
var destination: Vector2 = Vector2.ZERO

# State Varibales
enum State{
	WANDER,
	CHASE,
	ATTACK
}

func _ready() -> void:
	# Start Assignments
	health = max_health
	Sprite.play("Idle")
	state = State.WANDER
	HitboxSpawn.position = Vector2(hitbox_distance, 0)
	Healthbar.max_value = max_health
	Healthbar.value = health

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if health <= 0:
		_death()
		return
	
	# Check for player
	if player == null:
		state = State.WANDER
	
	#Direction and Destination
	if state == State.CHASE:
		if player.global_position.x > global_position.x:
			destination = player.global_position - Vector2(30,0)
		else:
			destination = player.global_position + Vector2(30,0)
	elif state == State.WANDER:
		if Cooldown.is_stopped():
			destination = Vector2(randi_range(-700,700), randi_range(-700,700))
			Cooldown.start(wanderTime)
	
	if state != State.ATTACK:
		if global_position.distance_to(destination) < 40:
			direction = Vector2.ZERO
			if state == State.CHASE:
				if player.global_position.x > global_position.x and Sprite.flip_h: # Facing Right
					Sprite.flip_h = false
					HitboxSpawn.position = Vector2(hitbox_distance, 0)
				elif player.global_position.x < global_position.x and !Sprite.flip_h: # Facing Left
					Sprite.flip_h = true
					HitboxSpawn.position = Vector2(-hitbox_distance, 0)
				if Cooldown.is_stopped():
					state = State.ATTACK
					Cooldown.start(cooldownTime)
		else: 
			direction = (destination - global_position).normalized()
			if direction.x > 0 and Sprite.flip_h: #Facing Right
				Sprite.flip_h = false
				HitboxSpawn.position = Vector2(hitbox_distance, 0)
			elif direction.x <0 and !Sprite.flip_h: #Facing left
				Sprite.flip_h = true
				HitboxSpawn.position = Vector2(-hitbox_distance, 0)
			Cooldown.start(cooldownTime/6)
	else:
		direction = Vector2.ZERO
	
	# State Machine
	match state:
		State.WANDER, State.CHASE:
			# Setting Velocity
			velocity.y = move_toward(velocity.y, direction.y * speed * MOVEMENT_MULTIPLIER, acceleration)
			velocity.x = move_toward(velocity.x, direction.x * speed * MOVEMENT_MULTIPLIER, acceleration)
		State.ATTACK:
			# Executing the attack
			direction = Vector2.ZERO
			if Sprite.animation != "Attack":
				_attack()
			velocity.y = move_toward(velocity.y, 0, acceleration)
			velocity.x = move_toward(velocity.x, 0, acceleration)
	
	_animation_check()
	move_and_slide()

func _animation_check() -> void:
	if state == State.ATTACK:
		if Sprite.animation != "Attack":
			Sprite.play("Attack")
	elif (abs(velocity.x) < 0.01 and abs(velocity.y) < 0.01) and Sprite.animation != "Idle":
		Sprite.play("Idle")
	elif (abs(velocity.x) >= 0.01 and abs(velocity.y) >= 0.01) and Sprite.animation != "Run":
		Sprite.play("Run")

func _attack() -> void:
	var hitbox = Hitbox.new(damage, knockback * MOVEMENT_MULTIPLIER, 2, 1, 12, hitboxShape, true)
	HitboxSpawn.add_child(hitbox)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		state = State.CHASE

func _animation_finished() -> void:
	if Sprite.animation == "Attack":
		Sprite.play("Run")
		state = State.CHASE

func _death() -> void:
	Healthbar.visible = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1.5)
	await get_tree().create_timer(2).timeout
	queue_free()

func _update_healthbar() -> void:
	if health >=0:
		Healthbar.value = health
	else:
		Healthbar.value = 0
