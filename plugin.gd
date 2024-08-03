@tool
extends EditorPlugin

var animated_sprite_button: Button
var animation_copier

func _enter_tree():
	animation_copier = preload("res://addons/animation_copier/animation_copier.gd").new()
	animation_copier.editor_interface = get_editor_interface()
	
	# Add menu item
	add_tool_menu_item("Copy AnimatedSprite2D to AnimationPlayer", Callable(self, "_on_menu_item_pressed"))
	
	# Add toolbar button
	animated_sprite_button = Button.new()
	animated_sprite_button.text = "Copy to AnimationPlayer"
	animated_sprite_button.connect("pressed", Callable(self, "_on_copy_button_pressed"))
	
	# Try different container
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, animated_sprite_button)
	animated_sprite_button.hide()
	
	# Connect to the editor selection changed signal
	get_editor_interface().get_selection().connect("selection_changed", Callable(self, "_on_selection_changed"))
	
	print("Plugin entered tree, button added to container")

func _exit_tree():
	# Remove menu item
	remove_tool_menu_item("Copy AnimatedSprite2D to AnimationPlayer")
	
	# Remove toolbar button
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, animated_sprite_button)
	animated_sprite_button.queue_free()
	
	animation_copier.queue_free()
	
	print("Plugin exited tree, button removed")

func _on_selection_changed():
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	if selection.size() == 1 and selection[0] is AnimatedSprite2D:
		animated_sprite_button.show()
		print("AnimatedSprite2D selected, button shown")
	else:
		animated_sprite_button.hide()
		print("AnimatedSprite2D not selected, button hidden")

func _on_copy_button_pressed():
	print("Copy button pressed")
	var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()
	if selected_nodes.size() == 1 and selected_nodes[0] is AnimatedSprite2D:
		var animated_sprite = selected_nodes[0]
		animation_copier.copy_animations(animated_sprite)

func _on_menu_item_pressed():
	print("Menu item pressed")
	var edited_scene_root = get_editor_interface().get_edited_scene_root()
	if edited_scene_root:
		var animated_sprite = animation_copier.find_node_by_type(edited_scene_root, "AnimatedSprite2D")
		if animated_sprite:
			animation_copier.copy_animations(animated_sprite)
		else:
			printerr("No AnimatedSprite2D found in the current scene.")
	else:
		printerr("No scene is currently being edited.")

func _process(delta):
	# Check button visibility in every frame (for debugging)
	if is_instance_valid(animated_sprite_button):
		print("Button visibility: ", animated_sprite_button.visible)
