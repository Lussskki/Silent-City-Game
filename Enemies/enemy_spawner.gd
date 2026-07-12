extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_count := 5
@export var spawn_areas: Array[Rect2] = [
	Rect2(620, 360, 380, 1),
	Rect2(1080, 360, 420, 1),
	Rect2(1520, 360, 520, 1),
	Rect2(-1120, 500, 420, 1),
	Rect2(320, 860, 360, 1),
	Rect2(760, 1000, 520, 1),
	Rect2(-1120, -170, 360, 1)
]

const CHARACTER_NAMES := [
	"Adventurer",
	"Female",
	"Player",
	"Soldier",
	"Zombie"
]

func _ready() -> void:
	randomize()
	_spawn_enemies()


func _spawn_enemies() -> void:
	if not enemy_scene:
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var areas := spawn_areas.duplicate()
	areas.shuffle()
	var characters := CHARACTER_NAMES.duplicate()
	characters.shuffle()

	var amount: int = min(spawn_count, areas.size(), characters.size())
	for index in amount:
		var area: Rect2 = areas[index]
		var enemy := enemy_scene.instantiate() as Node2D
		enemy.position = Vector2(
			rng.randf_range(area.position.x, area.end.x),
			rng.randf_range(area.position.y, area.end.y)
		)
		enemy.set("random_character", false)
		enemy.set("character_name", characters[index])
		add_child(enemy)
