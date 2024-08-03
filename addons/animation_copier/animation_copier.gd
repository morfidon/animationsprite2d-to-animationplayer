@tool
extends Node

var editor_interface: EditorInterface

func copy_animations(animated_sprite: AnimatedSprite2D):
	var animation_player = _find_or_create_animation_player(animated_sprite)
	
	if not animation_player:
		printerr("Failed to find or create AnimationPlayer.")
		return

	var animation_library = animation_player.get_animation_library("SpriteAnimations")
	if not animation_library:
		animation_library = AnimationLibrary.new()
		animation_player.add_animation_library("SpriteAnimations", animation_library)

	var animation_names = animated_sprite.sprite_frames.get_animation_names()
	print("Animations found in AnimatedSprite2D: ", animation_names)

	for anim_name in animation_names:
		if animation_library.has_animation(anim_name):
			print("Animation already exists: ", anim_name)
			continue

		print("Processing animation: ", anim_name)
		var animation = Animation.new()
		var frame_count = animated_sprite.sprite_frames.get_frame_count(anim_name)
		var fps = animated_sprite.sprite_frames.get_animation_speed(anim_name)
		print("Frame count: ", frame_count, ", FPS: ", fps)

		var animation_duration = frame_count / float(fps)
		animation.length = animation_duration

		var track_index = animation.add_track(Animation.TYPE_VALUE)
		var path_to_sprite = animation_player.get_node(animated_sprite.get_path()).get_path()
		animation.track_set_path(track_index, NodePath(str(path_to_sprite) + ":animation"))
		animation.track_insert_key(track_index, 0, anim_name)

		var frame_track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(frame_track_index, NodePath(str(path_to_sprite) + ":frame"))

		for frame in range(frame_count):
			var time = frame / float(fps)
			animation.track_insert_key(frame_track_index, time, frame)
		
		# Ensure the last frame extends to the end of the animation
		animation.track_insert_key(frame_track_index, animation_duration, frame_count - 1)

		animation.loop_mode = Animation.LOOP_LINEAR if animated_sprite.sprite_frames.get_animation_loop(anim_name) else Animation.LOOP_NONE

		animation_library.add_animation(anim_name, animation)
		print("Added animation to library: ", anim_name)

	print("Animations copied successfully!")
	_print_animations(animation_player)

	editor_interface.get_resource_filesystem().scan()

func _find_or_create_animation_player(animated_sprite: AnimatedSprite2D) -> AnimationPlayer:
	print("Finding or creating AnimationPlayer for AnimatedSprite2D: ", animated_sprite)
	var animation_player = _find_animation_player_in_children(animated_sprite)
	
	if not animation_player:
		print("No AnimationPlayer found in children. Checking parent.")
		animation_player = _find_animation_player_in_parent(animated_sprite)
	
	if not animation_player:
		print("No AnimationPlayer found in parent. Creating new AnimationPlayer.")
		animation_player = AnimationPlayer.new()
		animated_sprite.add_child(animation_player)
		animation_player.owner = editor_interface.get_edited_scene_root()
		print("Created new AnimationPlayer")
	
	return animation_player

# Check if AnimationPlayer exists in the direct parent of AnimatedSprite2D
func _find_animation_player_in_parent(node: Node) -> AnimationPlayer:
	var parent_node = node.get_parent()
	print("Checking direct parent node for AnimationPlayer: ", parent_node)
	if parent_node:
		for child in parent_node.get_children():
			if child is AnimationPlayer:
				print("Found AnimationPlayer in direct parent node: ", child)
				return child
		print("Direct parent node is not AnimationPlayer, it is: ", parent_node.get_class())
	print("No AnimationPlayer found in direct parent node.")
	return null

# Recursive search for AnimationPlayer in children nodes
func _find_animation_player_in_children(node: Node) -> AnimationPlayer:
	print("Checking children nodes for AnimationPlayer: ", node)
	for child in node.get_children():
		print("Checking child node: ", child)
		if child is AnimationPlayer:
			print("Found AnimationPlayer in child node: ", child)
			return child
		var found = _find_animation_player_in_children(child)
		if found:
			return found
	print("No AnimationPlayer found in children nodes.")
	return null

func _print_animations(animation_player: AnimationPlayer):
	print("Animation libraries in AnimationPlayer:")
	var libraries = animation_player.get_animation_library_list()
	for lib in libraries:
		print("Library: ", lib)
		var animations = animation_player.get_animation_library(lib).get_animation_list()
		for anim in animations:
			print("- ", anim)

func find_node_by_type(node: Node, type_name: String) -> Node:
	if node.get_class() == type_name:
		return node
	for child in node.get_children():
		var found = find_node_by_type(child, type_name)
		if found:
			return found
	return null
