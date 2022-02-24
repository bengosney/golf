extends Node2D


func _on_TileMap_init_level():
	$Player.position = Vector2.ZERO
	$Ball.global_transform.origin = Vector2.RIGHT * 3
