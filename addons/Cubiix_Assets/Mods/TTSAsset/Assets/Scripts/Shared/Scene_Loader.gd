extends Node
@onready var Core = get_node("/root/Main_Scene/CoreLoader")
var Current_SceneID = ""
var Scene_Root

func load_scene(SceneID:String,PassThrough:Dictionary={}, SkipFade:bool = false, SpawnLocation:String = "") -> void:
	var SceneData = Core.AssetData.find_map(SceneID)
	var current_scene = get_tree().root.get_node("Main_Scene/Current_Scene")
	#print(SceneData)
	if SceneData.has("Image_Preview") && SceneData.has("Name") && SceneData.has("Description"):
		Current_SceneID = SceneID
		Core.Persistant_Core.Transitioner.get_node("TextureRect/RichTextLabel").text = "[center][font_size=40] [b]"+SceneData["Name"]+"[/b][/font_size]\n"+SceneData["Description"]
		Core.Persistant_Core.Transitioner.get_node("TextureRect").texture = load(SceneData["Image_Preview"])
		
		if !SkipFade:
			Core.Persistant_Core.Transitioner_AnimationPlayer.play_backwards("FadeOut")
			await Core.Persistant_Core.Transitioner_AnimationPlayer.animation_finished
		if current_scene.get_child_count() > 0:
			current_scene.remove_child(current_scene.get_child(0))
			
		var load_scene = load(SceneData["Server_Path"]).instantiate()
		#print(SceneData["Client_Path"])
		load_scene.client_string = SceneData["Client_Path"]
		
		
		current_scene.add_child(load_scene)
		Scene_Root = load_scene
		load_scene.setup()
		await load_scene.FinishedLoad
		#if SpawnLocation != "" && SceneData["Spawn_Locations"].has(SpawnLocation):
			#Core.Persistant_Core.SpawnAt(str_to_var(SceneData["Spawn_Locations"][SpawnLocation][0]), str_to_var(SceneData["Spawn_Locations"][SpawnLocation][1]))
		#else:
			#Core.Persistant_Core.SpawnAt(Vector3.ZERO, Vector3.ZERO)
		Core.Persistant_Core.Transitioner_AnimationPlayer.play("FadeOut")
		
	else:
		pass
		#print("Error: Invalid Map Data")
