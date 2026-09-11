extends CharacterBody2D

# Movement Variables
@export var speed: float = 20
@export var max_health: float = 100
@export var acceleration: float = 16
@export var friction: float = 1

# Node Variables
@export var Sprite: AnimatedSprite2D

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
	pass

func _physics_process(delta: float) -> void:
	pass
