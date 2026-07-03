extends CharacterBody2D

const WALK_SPEED = 250.0
const RUN_SPEED = 450.0
const JUMP_VELOCITY = -600.0

@onready var sprite = $AnimatedSprite2D

var attacking = false

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !attacking:
		velocity.y = JUMP_VELOCITY

	# Attack
	if Input.is_action_just_pressed("attack") and !attacking:
		attacking = true
		if is_on_floor():
			sprite.play("Slashing")
		else:
			sprite.play("Slashing In Air")

	# Movement
	var direction := Input.get_axis("ui_left", "ui_right")
	var speed := WALK_SPEED
	if Input.is_action_pressed("run"):
		speed = RUN_SPEED

	if direction != 0:
		velocity.x = direction * speed
		sprite.flip_h = direction < 0
	else:
		velocity.x = 0

	move_and_slide()

	if attacking:
		if not sprite.is_playing():
			attacking = false
		else:
			return

	# Animations
	if not is_on_floor():
		if velocity.y < 0:
			if sprite.animation != "Jump Looping":
				sprite.play("Jump Looping")
		else:
			if sprite.animation != "Falling Down":
				sprite.play("Falling Down")

	elif Input.is_action_pressed("ui_down"):
		if sprite.animation != "Sliding":
			sprite.play("Sliding")

	elif direction != 0:
		if Input.is_action_pressed("run"):
			if sprite.animation != "Running":
				sprite.play("Running")
		else:
			if sprite.animation != "Walking":
				sprite.play("Walking")

	else:
		if sprite.animation != "Idle":
			sprite.play("Idle")


func _on_animation_finished():
	if sprite.animation == "Slashing" or sprite.animation == "Slashing In Air":
		attacking = false
