extends CharacterBody2D

@export var max_life: int = 100
@export var move_speed := 95.0
@export var chase_distance := 520.0
@export var attack_distance := 95.0
@export var attack_vertical_tolerance := 95.0
@export var attack_damage: int = 10
@export var attack_cooldown := 1.0
@export var hurt_cooldown := 0.35
@export var random_character := true
@export var character_name := ""

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar

const CHARACTER_NAMES := [
	"Adventurer",
	"Female",
	"Player",
	"Soldier",
	"Zombie"
]

var life: int = 100
var player: Node2D
var attack_timer := 0.0
var hurt_timer := 0.0
var dead := false
var character_key := ""
var idle_texture: Texture2D
var walk_textures: Array[Texture2D] = []
var attack_texture: Texture2D
var hurt_texture: Texture2D
var flip_direction := false

func _ready() -> void:
	add_to_group("Enemy")
	add_to_group("enemy")
	life = max_life
	_setup_random_character()
	_find_player()
	_update_health_bar()


func _physics_process(delta: float) -> void:
	if dead:
		return

	attack_timer = max(attack_timer - delta, 0.0)
	hurt_timer = max(hurt_timer - delta, 0.0)

	if not player:
		_find_player()

	if not is_on_floor():
		velocity += get_gravity() * delta

	if player:
		var enemy_position := get_hit_position()
		var player_position := _get_player_hit_position()
		var distance := enemy_position.distance_to(player_position)
		var direction: float = sign(player_position.x - enemy_position.x)
		var player_in_attack_range := _is_player_in_attack_range()

		if distance <= chase_distance and not player_in_attack_range:
			velocity.x = direction * move_speed
			flip_direction = direction < 0
			sprite.flip_h = flip_direction
			_show_walk_pose()
		else:
			velocity.x = move_toward(velocity.x, 0.0, move_speed)
			_show_idle_pose()

		if player_in_attack_range:
			_try_attack_player()
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		_show_idle_pose()

	move_and_slide()


func take_damage(amount: int) -> void:
	if dead:
		return

	life = max(life - amount, 0)
	_update_health_bar()
	_show_hurt_pose()
	modulate = Color(1.0, 0.45, 0.45)

	if life <= 0:
		_die()
		return

	await get_tree().create_timer(0.12).timeout
	if not dead:
		modulate = Color.WHITE


func get_hit_position() -> Vector2:
	return sprite.global_position


func _find_player() -> void:
	player = get_tree().get_first_node_in_group("Player") as Node2D


func _try_attack_player() -> void:
	if attack_timer > 0.0:
		return
	if not player:
		return
	if not _is_player_in_attack_range():
		return

	attack_timer = attack_cooldown
	_show_attack_pose()
	if player and player.has_method("take_damage"):
		player.take_damage(attack_damage)


func _try_take_player_hit(distance: float) -> void:
	if hurt_timer > 0.0:
		return
	if not player or not player.has_method("is_attacking_enemy"):
		return
	if distance > attack_distance + 45.0:
		return
	if not player.is_attacking_enemy():
		return

	hurt_timer = hurt_cooldown
	var damage := 25
	if player.has_method("get_attack_damage"):
		damage = int(player.get_attack_damage())
	take_damage(damage)


func _get_player_hit_position() -> Vector2:
	if player and player.has_method("get_hit_position"):
		return player.get_hit_position()
	if player:
		return player.global_position
	return global_position


func _is_player_in_attack_range() -> bool:
	var hit_offset := _get_player_hit_position() - get_hit_position()
	return abs(hit_offset.x) <= attack_distance and abs(hit_offset.y) <= attack_vertical_tolerance


func _update_health_bar() -> void:
	health_bar.max_value = max_life
	health_bar.value = life


func _die() -> void:
	dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	modulate = Color(0.35, 0.35, 0.35, 0.75)
	await get_tree().create_timer(0.35).timeout
	queue_free()


func _setup_random_character() -> void:
	var names := CHARACTER_NAMES
	character_key = character_name
	if random_character or character_key.is_empty():
		character_key = names.pick_random()

	var prefix := character_key.to_lower()
	var pose_dir := "res://Characters/%s/Poses" % character_key

	idle_texture = load("%s/%s_idle.png" % [pose_dir, prefix]) as Texture2D
	walk_textures = [
		load("%s/%s_walk1.png" % [pose_dir, prefix]) as Texture2D,
		load("%s/%s_walk2.png" % [pose_dir, prefix]) as Texture2D
	]
	attack_texture = load("%s/%s_action1.png" % [pose_dir, prefix]) as Texture2D
	hurt_texture = load("%s/%s_hurt.png" % [pose_dir, prefix]) as Texture2D

	if idle_texture:
		sprite.texture = idle_texture


func _show_idle_pose() -> void:
	if attack_timer > attack_cooldown - 0.18:
		return
	if idle_texture and sprite.texture != idle_texture:
		sprite.texture = idle_texture


func _show_walk_pose() -> void:
	if attack_timer > attack_cooldown - 0.18:
		return
	if walk_textures.is_empty():
		return

	var index := int(Time.get_ticks_msec() / 220) % walk_textures.size()
	if walk_textures[index]:
		sprite.texture = walk_textures[index]


func _show_attack_pose() -> void:
	if attack_texture:
		sprite.texture = attack_texture


func _show_hurt_pose() -> void:
	if hurt_texture:
		sprite.texture = hurt_texture
