extends CharacterBody2D

# Movement Variables
@export var speed: float = 20
@export var max_health: float = 50
@export var acceleration: float = 16
@export var damage: float = 5
@export var knockback: float = 18

# Node Variable
@export var Sprite: AnimatedSprite2D

# hitbox variables
@export var HitboxSpawn: Node2D
@export var hitboxShape: Shape2D
@export var hitbox_distance: int = 32
@export var Healthbar: TextureProgressBar

# Internal Variables
const MOVEMENT_MULTIPLIER: float = 16
var health: float
var state: int

# State Variables
enum State {
	IDLE,
	RUN,
	ATTACK
}

func _ready() -> void:
	#Start Assignments
	health = max_health
	Sprite.play("Idle")
	state = State.IDLE
	HitboxSpawn.position = Vector2(hitbox_distance, 0)
	Healthbar.max_value = max_health
	Healthbar.value = health

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if health <= 0:
		_death()
		return
	
	# Idle Assignment
	if state != State.ATTACK:
		state = State.IDLE
	
	# Direction Calculation and Normalization
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("MoveLeft","MoveRight")
	direction.y = Input.get_axis("MoveUp", "MoveDown")
	direction = direction.normalized()
	
	# L/R Movement
	if direction.x != 0 and state != State.ATTACK:
		# State Assignent
		state = State.RUN
		
		# Set X Velocity
		velocity.x = move_toward(velocity.x, direction.x * speed * MOVEMENT_MULTIPLIER, acceleration)
		
		# Direction Check
		if direction.x>0:# Facing Right
			if Sprite.flip_h:
				Sprite.flip_h = false
				HitboxSpawn.position = Vector2(hitbox_distance, 0)
		else: #facing left
			if !Sprite.flip_h:
				Sprite.flip_h = true
				HitboxSpawn.position = Vector2(-hitbox_distance, 0)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration)
	
	# U/D Movement
	if direction.y != 0 and state != State.ATTACK:
		#state Assignment
		state = State.RUN
		
		#Set Y Velocity
		velocity.y = move_toward(velocity.y, direction.y * speed * MOVEMENT_MULTIPLIER, acceleration)
	else:
		velocity.y = move_toward(velocity.y, 0, acceleration)
	
	# Attack
	if Input.is_action_just_pressed("Attack") and state != State.ATTACK:
		#Attack State
		state = State.ATTACK
		
		_attack()
	
	_animation_check()
	move_and_slide()

func _animation_check() -> void:
	match state:
		State.IDLE:
			if Sprite.animation != "Idle":
				Sprite.play("Idle")
		State.RUN:
			if Sprite.animation != "Run":
				Sprite.play("Run")
		State.ATTACK:
			if Sprite.animation != "Attack":
				Sprite.play("Attack")

func _attack() -> void:
	var hitbox = Hitbox.new(damage, knockback * MOVEMENT_MULTIPLIER, 2, 1, 12, hitboxShape, false)
	HitboxSpawn.add_child(hitbox)

func _animation_finished() -> void:	
	if Sprite.animation == "Attack":
		state = State.IDLE
		Sprite.play("Idle")

func _death() -> void:
	Healthbar.visible = false
	var tween = create_tween()
	tween.tween_property(get_parent().get_parent(), "modulate", Color(0,0,0), 1.5)
	await get_tree().create_timer(5).timeout
	get_tree().reload_current_scene()

func _update_healthbar() -> void:
	if health >=0:
		Healthbar.value = health
	else:
		Healthbar.value = 0
