@tool
extends EditorPlugin

# UI Components
var import_button
var file_dialog
var selected_directory = ""

# Called when the plugin is added to the editor
func _enter_tree():
	# Add the custom interface
	create_custom_interface()

# Called when the plugin is removed from the editor
func _exit_tree():
	# Remove the custom interface
	remove_custom_control()

func create_custom_interface():
	# Create a file dialog to select directories
	file_dialog = FileDialog.new()
	file_dialog.mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.connect("dir_selected", self, "_on_directory_selected")
	add_child(file_dialog)
	
	# Create an import button
	import_button = Button.new()
	import_button.text = "Import Animations"
	import_button.connect("pressed", self, "_on_import_button_pressed")
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, import_button)

func remove_custom_control():
	remove_control_from_docks(import_button)
	file_dialog.queue_free()
	import_button.queue_free()

# Called when the user selects a directory
func _on_directory_selected(directory):
	selected_directory = directory
	print("Selected directory: " + selected_directory)

# Called when the import button is pressed
func _on_import_button_pressed():
	if selected_directory == "":
		print("No directory selected!")
		return
	
	# Import animations
	var xml_file = selected_directory + "/AnimData.xml"
	if not FileAccess.file_exists(xml_file):
		print("AnimData.xml not found in the selected directory!")
		return
	
	var new_output_dir = selected_directory + "/ImportedAnimations"
	DirAccess.make_dir_recursive_absolute(new_output_dir)
	
	var animations = import_animations(xml_file, new_output_dir)
	create_animated_sprite_scene(animations, new_output_dir)

func import_animations(xml_file: String, output_dir: String) -> Dictionary:
	var animations = {}
	var xml = XMLParser.new()
	if xml.open(xml_file) != OK:
		print("Failed to open AnimData.xml")
		return animations
	
	while xml.read() == OK:
		if xml.get_node_type() == XMLParser.NODE_ELEMENT:
			if xml.get_node_name() == "Anim":
				var anim_name = ""
				var frame_width = 0
				var frame_height = 0
				var durations = []
				
				while xml.read() == OK:
					if xml.get_node_name() == "Name":
						anim_name = xml.get_node_data()
					elif xml.get_node_name() == "FrameWidth":
						frame_width = int(xml.get_node_data())
					elif xml.get_node_name() == "FrameHeight":
						frame_height = int(xml.get_node_data())
					elif xml.get_node_name() == "Duration":
						durations.append(int(xml.get_node_data()))
					elif xml.get_node_type() == XMLParser.NODE_ELEMENT_END and xml.get_node_name() == "Anim":
						break
				
				# Load the sprite sheet for this animation
				var sprite_sheet_path = selected_directory + "/" + anim_name + "-Anim.png"
				if FileAccess.file_exists(sprite_sheet_path):
					var sprite_sheet = load(sprite_sheet_path)
					var animation_path = save_animation(anim_name, frame_width, frame_height, durations, sprite_sheet, output_dir)
					if animation_path:
						animations[anim_name] = animation_path
				else:
					print("Sprite sheet not found for animation: " + anim_name)
	
	return animations

func save_animation(name: String, width: int, height: int, durations: Array, sprite_sheet: Texture, output_dir: String) -> String:
	var frames = SpriteFrames.new()
	var frame_count = len(durations)
	
	for i in range(frame_count):
		var frame_region = Rect2(Vector2(i * width, 0), Vector2(width, height))
		var sub_image = sprite_sheet.get_rect_region(frame_region)
		frames.add_frame(name, sub_image)
		frames.set_frame_duration(name, i, durations[i] / 60.0)  # Assuming duration is in frames
	
	var animation_resource_path = output_dir + "/" + name + ".tres"
	if ResourceSaver.save(animation_resource_path, frames) == OK:
		print("Saved animation: " + name + " at " + animation_resource_path)
		return animation_resource_path
	else:
		print("Failed to save animation: " + name)
		return ""

# Create the scene with the AnimatedSprite2D node
func create_animated_sprite_scene(animations: Dictionary, output_dir: String):
	var scene = Node2D.new()
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.frames = SpriteFrames.new()
	
	# Attach all animations to the AnimatedSprite2D node
	for anim_name in animations.keys():
		var frames = load(animations[anim_name])
		if frames:
			for i in range(frames.get_frame_count(anim_name)):
				animated_sprite.frames.add_frame(anim_name, frames.get_frame(anim_name, i))
			animated_sprite.frames.set_animation_speed(anim_name, frames.get_animation_speed(anim_name))
			animated_sprite.frames.set_animation_loop(anim_name, frames.is_animation_looping(anim_name))
	
	# Add the AnimatedSprite2D node to the scene
	scene.add_child(animated_sprite)
	
	# Save the scene as a .tscn file
	var scene_path = output_dir + "/AnimatedSpriteScene.tscn"
	var packed_scene = PackedScene.new()
	packed_scene.pack(scene)
	
	if ResourceSaver.save(scene_path, packed_scene) == OK:
		print("Saved scene: " + scene_path)
	else:
		print("Failed to save scene")
