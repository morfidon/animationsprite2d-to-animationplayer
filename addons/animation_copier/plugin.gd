@tool
extends EditorPlugin

var animation_copier

func _enter_tree():
	animation_copier = preload("res://addons/animation_copier/animation_copier.gd").new()
	add_tool_menu_item("Copy AnimatedSprite2D to AnimationPlayer", animation_copier.copy_animations)

func _exit_tree():
	remove_tool_menu_item("Copy AnimatedSprite2D to AnimationPlayer")
	animation_copier.queue_free()
