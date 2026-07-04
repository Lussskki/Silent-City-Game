extends CharacterBody2D

const WALK_SPEED = 250.0
const RUN_SPEED = 450.0
const JUMP_VELOCITY = -600.0
const SLIDE_SPEED = 400.0
const SLIDE_ANGLE = 15.0

@onready var sprite = $AnimatedSprite2D
@onready var slide_collision = $CollisionShape2D

var attacking = false
var is_sliding = false

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)

	# ტაილების ფერდობი კიბესავით კვადრატებისგან შედგება (~51°).
	# ამ პარამეტრებით პერსონაჟი კიბეს გლუვ ფერდობად აღიქვამს და
	# საფეხურებზე აღარ ახტება ზემოთ-ქვემოთ.
	floor_max_angle = deg_to_rad(60)   # ციცაბო კიბე „იატაკად" ჩაითვალოს
	floor_snap_length = 80.0            # საფეხურებზე მიწებება, ჰაერში აღარ ახტეს
	floor_constant_speed = true         # ფერდობზე სიჩქარე მუდმივი დარჩეს

func _physics_process(delta):

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not attacking and not is_sliding:
		velocity.y = JUMP_VELOCITY

	# Attack
	if Input.is_action_just_pressed("attack") and not attacking:
		attacking = true
		if is_on_floor():
			if Input.is_action_pressed("run"):
				_safe_play("Run Slashing")
			else:
				_safe_play("Slashing")
		else:
			_safe_play("Slashing In Air")

	# Kick
	if Input.is_action_just_pressed("kick") and not attacking:
		attacking = true
		_safe_play("Kicking")

	# Throw
	if Input.is_action_just_pressed("throw") and not attacking:
		attacking = true
		if is_on_floor():
			_safe_play("Throwing")
		else:
			_safe_play("Throwing In Air")

	# Movement
	var direction := Input.get_axis("ui_left", "ui_right")
	var speed := WALK_SPEED

	if Input.is_action_pressed("run"):
		speed = RUN_SPEED

	if direction != 0:
		velocity.x = direction * speed
		sprite.flip_h = direction < 0
		
		# დახრილ ადგილზე INPUT - Y უნდა იყოს downhill მიმართულება
		if is_on_floor():
			var angle = abs(rad_to_deg(get_floor_angle()))
			if angle > SLIDE_ANGLE:
				var normal = get_floor_normal()
				var downhill = Vector2(normal.y, -normal.x)
				if downhill.y < 0:
					downhill = -downhill
				downhill = downhill.normalized()
				velocity.y = downhill.y * SLIDE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

# Automatic slope sliding


	if is_on_floor():
		var angle = abs(rad_to_deg(get_floor_angle()))

		if angle > SLIDE_ANGLE:
			is_sliding = true

			# თუ INPUT არ არის, downhill-ით სრიალი
			if direction == 0:
				var normal = get_floor_normal()
				var downhill = Vector2(normal.y, -normal.x)
				if downhill.y < 0:
					downhill = -downhill
				downhill = downhill.normalized()
				velocity = downhill * SLIDE_SPEED
			# თუ INPUT არის, INPUT-ით სრიალი
		else:
			is_sliding = false

	move_and_slide()

	
	

	# Stop movement while attacking
	if attacking:
		if not sprite.is_playing():
			attacking = false
		else:
			return

	# Animations
	if not is_on_floor():
		if velocity.y < 0:
			if sprite.animation != "Jump Looping":
				_safe_play("Jump Looping")
		else:
			if sprite.animation != "Falling Down":
				_safe_play("Falling Down")

	elif is_sliding:
		if sprite.animation != "Sliding":
			_safe_play("Sliding")

	elif direction != 0:
		if Input.is_action_pressed("run"):
			if sprite.animation != "Running":
				_safe_play("Running")
		else:
			if sprite.animation != "Walking":
				_safe_play("Walking")

	else:
		if sprite.animation != "Idle":
			_safe_play("Idle")


func _on_animation_finished():
	if sprite.animation in [
		"Slashing",
		"Slashing In Air",
		"Run Slashing",
		"Kicking",
		"Throwing",
		"Throwing In Air"
	]:
		attacking = false


func _safe_play(name: String) -> void:
	if _has_animation(name):
		sprite.play(name)


func _has_animation(name: String) -> bool:
	if not sprite:
		return false

	var frames = null

	if sprite.has_method("get_sprite_frames"):
		frames = sprite.get_sprite_frames()
	else:
		for p in sprite.get_property_list():
			if p is Dictionary and p.has("name"):
				if p["name"] == "frames" or p["name"] == "sprite_frames":
					frames = sprite.get(p["name"])
					break

	if frames and frames.has_animation(name):
		return true

	return false
