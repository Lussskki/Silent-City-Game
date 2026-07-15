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
	_add_platform("StartPlatform", Rect2(0, 500, 512, 256))
	_add_platform("NeedlePlatformA", Rect2(640, 370, 256, 128))
	_add_platform("NeedlePlatformB", Rect2(1030, 250, 256, 128))
	_add_platform("SafeStep", Rect2(1420, 420, 256, 128))
	_add_platform("HighTower", Rect2(1790, 230, 384, 512))
	_add_platform("DropPlatform", Rect2(2300, 560, 256, 128))
	_add_platform("TinyBridge", Rect2(2700, 410, 256, 128))
	_add_platform("FinalPlatform", Rect2(3090, 285, 384, 384))

	_add_spike_pit(Vector2(512, 710), 3)
	_add_spike_pit(Vector2(900, 710), 4)
	_add_spike_pit(Vector2(1285, 710), 4)
	_add_spike_pit(Vector2(2560, 710), 4)

	_add_gun_pickup(Vector2(760, 346))
	_add_gun_pickup(Vector2(1915, 206))

	_add_sprite("StartTree", tree_texture, Vector2(110, 380), Vector2(1.25, 1.25))
	_add_sprite("StartSkeleton", skeleton_texture, Vector2(300, 470), Vector2(1.15, 1.15))
	_add_sprite("StartCrate", crate_texture, Vector2(430, 448), Vector2(0.95, 0.95))

	_add_sprite("PlatformATombstone", tombstone_b_texture, Vector2(700, 330), Vector2(1.6, 1.6))
	_add_sprite("PlatformABush", bush_texture, Vector2(825, 348), Vector2(0.65, 0.65))

	_add_sprite("PlatformBCrate", crate_texture, Vector2(1165, 198), Vector2(0.95, 0.95))
	_add_sprite("SafeStepSign", sign_texture, Vector2(1500, 374), Vector2(1.0, 1.0))

	_add_sprite("TowerTombstone", tombstone_a_texture, Vector2(1875, 164), Vector2(1.65, 1.65))
	_add_sprite("TowerDeadBush", dead_bush_texture, Vector2(2050, 196), Vector2(0.8, 0.8))
	_add_sprite("TowerCrate", crate_texture, Vector2(2115, 178), Vector2(0.95, 0.95))

	_add_sprite("DropDeadBush", dead_bush_texture, Vector2(2395, 529), Vector2(0.8, 0.8))
	_add_sprite("TinyBridgeCrate", crate_texture, Vector2(2790, 358), Vector2(0.95, 0.95))

	_add_sprite("FinalTombstone", tombstone_a_texture, Vector2(3200, 220), Vector2(1.8, 1.8))
	_add_sprite("FinalTree", tree_texture, Vector2(3420, 168), Vector2(-1.15, 1.15))


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
