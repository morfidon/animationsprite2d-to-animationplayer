@tool
extends EditorPlugin

func copy_animations():
	var edited_scene_root = get_editor_interface().get_edited_scene_root()
	if not edited_scene_root:
		printerr("No scene is currently being edited.")
		return

	var animated_sprite = find_node_by_type(edited_scene_root, "AnimatedSprite2D")
	var animation_player = find_node_by_type(edited_scene_root, "AnimationPlayer")

	if not animated_sprite:
		printerr("AnimatedSprite2D not found in the scene.")
		return
	if not animation_player:
		printerr("AnimationPlayer not found in the scene.")
		return

	print("AnimatedSprite2D found: ", animated_sprite.name)
	print("AnimationPlayer found: ", animation_player.name)

	var animation_library = AnimationLibrary.new()
	var animation_names = animated_sprite.sprite_frames.get_animation_names()
	print("Animations found in AnimatedSprite2D: ", animation_names)

	for anim_name in animation_names:
		print("Processing animation: ", anim_name)
		var animation = Animation.new()
		var frame_count = animated_sprite.sprite_frames.get_frame_count(anim_name)
		var fps = animated_sprite.sprite_frames.get_animation_speed(anim_name)
		print("Frame count: ", frame_count, ", FPS: ", fps)

		animation.length = frame_count / float(fps)
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		
		var path_to_sprite = animation_player.get_node(animated_sprite.get_path()).get_path()
		var property_path = ":animation"
		var full_path = str(path_to_sprite) + property_path
		animation.track_set_path(track_index, NodePath(full_path))
		
		# Set the animation name
		animation.track_insert_key(track_index, 0, anim_name)

		# Add frame track
		var frame_track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(frame_track_index, str(path_to_sprite) + ":frame")

		for frame in range(frame_count):
			var time = frame / float(fps)
			animation.track_insert_key(frame_track_index, time, frame)

		animation.loop_mode = Animation.LOOP_LINEAR if animated_sprite.sprite_frames.get_animation_loop(anim_name) else Animation.LOOP_NONE

		animation_library.add_animation(anim_name, animation)
		print("Added animation to library: ", anim_name)

	# Remove existing SpriteAnimations library if it exists
	if animation_player.has_animation_library("SpriteAnimations"):
		animation_player.remove_animation_library("SpriteAnimations")

	animation_player.add_animation_library("SpriteAnimations", animation_library)

	print("Animations copied successfully!")
	print_animations(animation_player)

	# Mark the scene as changed
	get_editor_interface().get_resource_filesystem().scan()

func find_node_by_type(node: Node, type_name: String) -> Node:
	if node.get_class() == type_name:
		return node
	for child in node.get_children():
		var found = find_node_by_type(child, type_name)
		if found:
			return found
	return null

func print_animations(animation_player: AnimationPlayer):
	print("Animation libraries in AnimationPlayer:")
	var libraries = animation_player.get_animation_library_list()
	for lib in libraries:
		print("Library: ", lib)
		var animations = animation_player.get_animation_library(lib).get_animation_list()
		for anim in animations:
			print("- ", anim)
