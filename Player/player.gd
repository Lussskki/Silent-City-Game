extends CharacterBody2D

const WALK_SPEED = 250.0
const RUN_SPEED = 450.0
const JUMP_VELOCITY = -600.0
const SLIDE_SPEED = 400.0
const SLIDE_ANGLE = 15.0

signal life_changed(life: int, max_life: int)

@export_group("Character Sounds")
@export var jump_sound: AudioStream
@export var run_sound: AudioStream
@export var attack_sound: AudioStream
@export var kick_sound: AudioStream
@export var shoot_sound: AudioStream
@export_range(-80.0, 6.0, 0.5) var character_sound_volume_db := -8.0
@export_range(0.1, 2.0, 0.05) var run_sound_interval := 0.35
@export_group("Player Life")
@export var max_life: int = 100
@export_group("Combat")
@export var attack_hit_radius := 130.0
@export var attack_vertical_tolerance := 95.0

@onready var sprite = $AnimatedSprite2D
@onready var slide_collision = $CollisionShape2D

var attacking = false
var is_sliding = false
var dead = false
var life: int = 100
var jump_audio: AudioStreamPlayer2D
var run_audio: AudioStreamPlayer2D
var attack_audio: AudioStreamPlayer2D
var kick_audio: AudioStreamPlayer2D
var shoot_audio: AudioStreamPlayer2D
var run_sound_timer := 0.0

func _ready():
	add_to_group("Player")
	add_to_group("player")
	life = max_life
	life_changed.emit(life, max_life)
	sprite.animation_finished.connect(_on_animation_finished)
	jump_audio = _create_sound_player("JumpSound", jump_sound)
	run_audio = _create_sound_player("RunSound", run_sound)
	attack_audio = _create_sound_player("AttackSound", attack_sound)
	kick_audio = _create_sound_player("KickSound", kick_sound)
	shoot_audio = _create_sound_player("ShootSound", shoot_sound)

	# ტაილების ფერდობი კიბესავით კვადრატებისგან შედგება (~51°).
	# ამ პარამეტრებით პერსონაჟი კიბეს გლუვ ფერდობად აღიქვამს და
	# საფეხურებზე აღარ ახტება ზემოთ-ქვემოთ.
	floor_max_angle = deg_to_rad(60)   # ციცაბო კიბე „იატაკად" ჩაითვალოს
	floor_snap_length = 80.0            # საფეხურებზე მიწებება, ჰაერში აღარ ახტეს
	floor_constant_speed = true         # ფერდობზე სიჩქარე მუდმივი დარჩეს

func _physics_process(delta):
	if dead:
		if not is_on_floor():
			velocity += get_gravity() * delta
			move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not attacking and not is_sliding:
		velocity.y = JUMP_VELOCITY
		_play_sound(jump_audio)

	# Attack
	if Input.is_action_just_pressed("attack") and not attacking:
		attacking = true
		_play_sound(attack_audio)
		if is_on_floor():
			if Input.is_action_pressed("run"):
				_safe_play("Run Slashing")
			else:
				_safe_play("Slashing")
		else:
			_safe_play("Slashing In Air")
		_damage_nearby_enemies()

	# Kick
	if Input.is_action_just_pressed("kick") and not attacking:
		attacking = true
		_play_sound(kick_audio)
		_safe_play("Kicking")
		_damage_nearby_enemies()

	# Throw
	if Input.is_action_just_pressed("throw") and not attacking:
		attacking = true
		_play_sound(shoot_audio)
		if is_on_floor():
			_safe_play("Throwing")
		else:
			_safe_play("Throwing In Air")
		_damage_nearby_enemies()

	# Movement
	var direction := Input.get_axis("ui_left", "ui_right")
	var speed := WALK_SPEED

	if Input.is_action_pressed("run"):
		speed = RUN_SPEED

	_update_run_sound(delta, direction)

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


func _create_sound_player(name: String, stream: AudioStream) -> AudioStreamPlayer2D:
	var player := AudioStreamPlayer2D.new()
	player.name = name
	player.stream = stream
	player.volume_db = character_sound_volume_db
	add_child(player)
	return player


func _play_sound(player: AudioStreamPlayer2D) -> void:
	if not player or not player.stream:
		return

	player.volume_db = character_sound_volume_db
	player.stop()
	player.play()


func _update_run_sound(delta: float, direction: float) -> void:
	var should_play_run := (
		direction != 0
		and is_on_floor()
		and Input.is_action_pressed("run")
		and not attacking
		and not is_sliding
	)

	if not should_play_run:
		run_sound_timer = 0.0
		return

	run_sound_timer -= delta
	if run_sound_timer <= 0.0:
		_play_sound(run_audio)
		run_sound_timer = run_sound_interval


func is_attacking_enemy() -> bool:
	return attacking and sprite.animation in [
		"Slashing",
		"Slashing In Air",
		"Run Slashing",
		"Kicking",
		"Throwing",
		"Throwing In Air"
	]


func get_attack_damage() -> int:
	match sprite.animation:
		"Kicking":
			return 20
		"Throwing", "Throwing In Air":
			return 15
		"Run Slashing":
			return 35
		_:
			return 25


func take_damage(amount: int) -> void:
	if dead:
		return

	life = max(life - amount, 0)
	life_changed.emit(life, max_life)
	if life <= 0:
		_die()
		return

	modulate = Color(1.0, 0.55, 0.55)
	await get_tree().create_timer(0.12).timeout
	if not dead:
		modulate = Color.WHITE


func get_hit_position() -> Vector2:
	return sprite.global_position


func _damage_nearby_enemies() -> void:
	var damage := get_attack_damage()
	var hit_origin: Vector2 = sprite.global_position
	var facing_direction := -1.0 if sprite.flip_h else 1.0
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not enemy is Node2D:
			continue

		var enemy_position: Vector2 = enemy.global_position
		if enemy.has_method("get_hit_position"):
			enemy_position = enemy.get_hit_position()

		var hit_offset := enemy_position - hit_origin
		if abs(hit_offset.x) > attack_hit_radius:
			continue
		if abs(hit_offset.y) > attack_vertical_tolerance:
			continue
		if abs(hit_offset.x) > 16.0 and sign(hit_offset.x) != facing_direction:
			continue
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)


func _die() -> void:
	dead = true
	attacking = false
	is_sliding = false
	velocity.x = 0.0
	modulate = Color.WHITE

	if _has_animation("Dying"):
		sprite.play("Dying")
	else:
		sprite.stop()
		modulate = Color(0.45, 0.45, 0.45, 0.85)

	await get_tree().create_timer(1.2).timeout
	get_tree().reload_current_scene()
