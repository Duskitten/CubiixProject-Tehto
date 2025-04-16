extends Control

func _ready():
	get_window().files_dropped.connect(on_files_dropped)
	print("Ok")
	
	
func on_files_dropped(files):
	for i in files:
		if i.ends_with(".png"):
			print(i)
			var template = $Panel.duplicate(true)
			var img = Image.new()
			var texture = ImageTexture.new()
			img.load(i)
			template.texture = texture.create_from_image(img)
			$ScrollContainer/GridContainer.add_child(template)
			template.show()
	await get_tree().process_frame
	$Topbar/HBoxContainer/ExportImageSize.text = "Export Image Size: "+ str(Vector2i($ScrollContainer/GridContainer.get_rect().size))
	
		

func _on_spin_box_value_changed(value: float) -> void:
	var newval = int(value)
	$ScrollContainer/GridContainer.columns = newval
	await get_tree().process_frame
	$Topbar/HBoxContainer/ExportImageSize.text = "Export Image Size: "+ str(Vector2i($ScrollContainer/GridContainer.get_rect().size))
	
		


func _on_button_2_pressed() -> void:
	$SubViewport.size = $ScrollContainer/GridContainer.get_rect().size
	var newimages:GridContainer = $ScrollContainer/GridContainer.duplicate(true)
	newimages.position = Vector2.ZERO
	$SubViewport/Control.add_child(newimages)
	await RenderingServer.frame_post_draw
	$SubViewport.get_texture().get_image().save_png("user://beep.png") 
	OS.shell_open(ProjectSettings.globalize_path("user://"))
