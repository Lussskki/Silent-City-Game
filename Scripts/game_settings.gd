extends Node

const MAIN_SCENE := "res://Scenes/Main.tscn"
const LAN_PORT := 8910
const LAN_MAX_ROUNDS := 5

signal lan_rounds_changed(rounds_played: int, max_rounds: int)

var selected_character := "player"
var character_chosen := false
var selected_level := "easy"
var level_chosen := false
var lan_mode := false
var lan_role := ""
var lan_remote_character := "golem"
var lan_tutorial_seen := false
var language := "eng"
var player_sprite_frames: SpriteFrames
var lan_rounds_played: int = 0
var lan_max_rounds: int = LAN_MAX_ROUNDS


func reset_lan() -> void:
	lan_mode = false
	lan_role = ""
	lan_remote_character = "golem"
	reset_lan_rounds()


func reset_lan_rounds() -> void:
	lan_rounds_played = 0
	lan_rounds_changed.emit(lan_rounds_played, LAN_MAX_ROUNDS)


func record_lan_round() -> void:
	if lan_rounds_played >= LAN_MAX_ROUNDS:
		return
	lan_rounds_played += 1
	lan_rounds_changed.emit(lan_rounds_played, LAN_MAX_ROUNDS)
