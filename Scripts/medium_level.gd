@tool
extends Node2D

const TILE_SIZE := 128.0

const TILE_TOP_LEFT := preload("res://Sprites/Tiles/Tile (1).png")
const TILE_TOP := preload("res://Sprites/Tiles/Tile (2).png")
const TILE_TOP_RIGHT := preload("res://Sprites/Tiles/Tile (3).png")
const TILE_LEFT := preload("res://Sprites/Tiles/Tile (4).png")
const TILE_FILL := preload("res://Sprites/Tiles/Tile (5).png")
const TILE_RIGHT := preload("res://Sprites/Tiles/Tile (6).png")
const TILE_BOTTOM_LEFT := preload("res://Sprites/Tiles/Tile (12).png")
const TILE_BOTTOM := preload("res://Sprites/Tiles/Tile (9).png")
const TILE_BOTTOM_RIGHT := preload("res://Sprites/Tiles/Tile (13).png")
const TILE_FLOAT_LEFT := preload("res://Sprites/Tiles/Tile (14).png")
const TILE_FLOAT_MIDDLE := preload("res://Sprites/Tiles/Tile (15).png")
const TILE_FLOAT_RIGHT := preload("res://Sprites/Tiles/Tile (16).png")
const GUN_PICKUP := preload("res://Scenes/GunPickup.tscn")

@export var spike_texture: Texture2D
@export var crate_texture: Texture2D
@export var tombstone_a_texture: Texture2D
@export var tombstone_b_texture: Texture2D
@export var tree_texture: Texture2D
@export var bush_texture: Texture2D
@export var dead_bush_texture: Texture2D
@export var skeleton_texture: Texture2D
@export var sign_texture: Texture2D
@export var hazard_script: Script

var generated_root: Node2D


func _ready() -> void:
	_rebuild_level()


func _rebuild_level() -> void:
	_clear_generated()
	generated_root = Node2D.new()
	generated_root.name = "Generated"
	add_child(generated_root)
	_mark_owned(generated_root)
	_build_level()


func _clear_generated() -> void:
	var existing := get_node_or_null("Generated")
	if existing:
		remove_child(existing)
		existing.free()


func _add_generated_child(node: Node) -> void:
	if not generated_root:
		add_child(node)
	else:
		generated_root.add_child(node)
	_mark_owned(node)


func _mark_owned(node: Node) -> void:
	if not Engine.is_editor_hint():
		return

	var edited_scene := get_tree().edited_scene_root
	if not edited_scene:
		return

	node.owner = edited_scene
	for child in node.get_children():
		_mark_owned(child)


func _build_level() -> void:
	_add_platform("StartPlatform", Rect2(0, 470, 640, 256))
	_add_platform("ShotgunPlatform", Rect2(640, 330, 384, 128))
	_add_platform("CenterPlatform", Rect2(1152, 430, 384, 128))
	_add_platform("HighTower", Rect2(1664, 270, 512, 512))
	_add_platform("StepPlatform", Rect2(2304, 410, 256, 128))
	_add_platform("LowerFightPlatform", Rect2(2176, 650, 512, 128))
	_add_platform("ExitPlatform", Rect2(2816, 500, 384, 256))

	_add_spike_pit(Vector2(896, 690), 5)
	_add_gun_pickup(Vector2(820, 306))
	_add_gun_pickup(Vector2(1870, 246))

	_add_sprite("StartTree", tree_texture, Vector2(120, 350), Vector2(1.35, 1.35))
	_add_sprite("StartSkeleton", skeleton_texture, Vector2(275, 440), Vector2(1.25, 1.25))
	_add_sprite("StartSign", sign_texture, Vector2(425, 424), Vector2(1.05, 1.05))
	_add_sprite("StartCrate", crate_texture, Vector2(535, 418), Vector2(1.0, 1.0))

	_add_sprite("ShotgunTombstone", tombstone_a_texture, Vector2(710, 271), Vector2(1.55, 1.55))
	_add_sprite("ShotgunBush", bush_texture, Vector2(920, 312), Vector2(0.75, 0.75))

	_add_sprite("CenterCrate", crate_texture, Vector2(1390, 376), Vector2(1.0, 1.0))
	_add_sprite("CenterDeadBush", dead_bush_texture, Vector2(1225, 399), Vector2(0.85, 0.85))

	_add_sprite("TowerTombstone", tombstone_a_texture, Vector2(1785, 204), Vector2(1.75, 1.75))
	_add_sprite("TowerBush", bush_texture, Vector2(1710, 250), Vector2(0.8, 0.8))
	_add_sprite("TowerCrate", crate_texture, Vector2(2095, 217), Vector2(1.0, 1.0))

	_add_sprite("LowerCrate", crate_texture, Vector2(2420, 597), Vector2(1.0, 1.0))
	_add_sprite("LowerDeadBush", dead_bush_texture, Vector2(2250, 619), Vector2(0.85, 0.85))

	_add_sprite("ExitTombstone", tombstone_b_texture, Vector2(2920, 450), Vector2(1.8, 1.8))
	_add_sprite("ExitTree", tree_texture, Vector2(3050, 385), Vector2(-1.15, 1.15))


func _add_platform(platform_name: String, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.name = platform_name
	body.position = rect.position + rect.size * 0.5
	_add_generated_child(body)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)

	var columns: int = max(1, int(round(rect.size.x / TILE_SIZE)))
	var rows: int = max(1, int(round(rect.size.y / TILE_SIZE)))
	for row in rows:
		for column in columns:
			var tile := Sprite2D.new()
			tile.name = "Tile_%d_%d" % [column, row]
			tile.texture = _platform_tile_texture(column, row, columns, rows)
			tile.position = Vector2(
				rect.position.x + TILE_SIZE * column + TILE_SIZE * 0.5,
				rect.position.y + TILE_SIZE * row + TILE_SIZE * 0.5
			)
			tile.z_index = -1
			_add_generated_child(tile)


func _platform_tile_texture(column: int, row: int, columns: int, rows: int) -> Texture2D:
	if rows == 1:
		if column == 0:
			return TILE_FLOAT_LEFT
		if column == columns - 1:
			return TILE_FLOAT_RIGHT
		return TILE_FLOAT_MIDDLE

	if row == 0:
		if column == 0:
			return TILE_TOP_LEFT
		if column == columns - 1:
			return TILE_TOP_RIGHT
		return TILE_TOP

	if row == rows - 1:
		if column == 0:
			return TILE_BOTTOM_LEFT
		if column == columns - 1:
			return TILE_BOTTOM_RIGHT
		return TILE_BOTTOM

	if column == 0:
		return TILE_LEFT
	if column == columns - 1:
		return TILE_RIGHT
	return TILE_FILL


func _add_spike_pit(start_position: Vector2, count: int) -> void:
	var hazard := Area2D.new()
	hazard.name = "SpikePitHazard"
	hazard.position = start_position + Vector2(TILE_SIZE * float(count) * 0.5, 32)
	if hazard_script:
		hazard.set_script(hazard_script)
	_add_generated_child(hazard)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(TILE_SIZE * count, 56)
	collision.shape = shape
	hazard.add_child(collision)

	for index in count:
		var spike := Sprite2D.new()
		spike.name = "Spike_%d" % index
		spike.texture = spike_texture
		spike.position = start_position + Vector2(TILE_SIZE * index + TILE_SIZE * 0.5, 0)
		spike.scale = Vector2(1.0, 1.0)
		_add_generated_child(spike)


func _add_gun_pickup(position: Vector2) -> void:
	var pickup := GUN_PICKUP.instantiate() as Node2D
	pickup.name = "GunPickup"
	pickup.position = position
	_add_generated_child(pickup)


func _add_sprite(sprite_name: String, texture: Texture2D, position: Vector2, scale: Vector2 = Vector2.ONE) -> void:
	if not texture:
		return

	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = texture
	sprite.position = position
	sprite.scale = scale
	_add_generated_child(sprite)
