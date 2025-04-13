extends Node

## How to load:
	#AssetData = load("res://addons/Cubiix_Assets/Scripts/Asset_Manager.gd").new()
	#AssetData.runsetup()
	#AssetData.name = "AssetData"
	#await AssetData.FinishedLoad
	#add_child(AssetData)

var mod_files = []
var mods = {}
var assets = {}
var compiled_assets = {}
var assets_tagged = {}

signal FinishedLoad
signal load_finished

var InitThread:Thread
var IsServer = false

func runsetup(Server:bool=false):
	IsServer = Server
	InitThread = Thread.new()
	InitThread.start(Init_ThreadRun)
	
	
func Init_ThreadRun():
	scan_for_mods("res://addons/Cubiix_Assets/Mods/")
	append_pck_mod(OS.get_executable_path().get_base_dir() + "/Mods/")
	scan_for_mods("res://addons/Cubiix_Assets/Mods/")
	compile_mod_assets()
	await self.load_finished
	if !IsServer:
		load_mod_assets()
		await self.load_finished
	call_deferred("Init_Finish")
	
func Init_Finish():
	InitThread.wait_to_finish()
	emit_signal("FinishedLoad")
	
func append_pck_mod(location:String) -> void:
	var dir = DirAccess.open(location)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				scan_for_mods(location + file_name)
			else:
				if file_name.to_lower().ends_with(".pck"):
					ProjectSettings.load_resource_pack(location+"/"+file_name)
			file_name = dir.get_next()


func scan_for_mods(location:String) -> void:
	var dir = DirAccess.open(location)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				scan_for_mods(location + file_name)
			else:
				if file_name == "Mod.json":
					if !mod_files.has(location+"/"+file_name):
						mod_files.append(location+"/"+file_name)
						break
			file_name = dir.get_next()

func compile_mod_assets() -> void:
	for i in mod_files:
		var file = FileAccess.open(i, FileAccess.READ)
		var content = JSON.parse_string(file.get_as_text())
		var modarray = {
			"ModID":"",
			"ModName":"",
			"ModDesc":""
		}
		if content.has("ModID") && !mods.has(content["ModID"]):
			for x in content.keys():
				match x:
					"ModID", "ModName", "ModDesc":
						modarray[x] = content[x]
			mods[content["ModID"]] = modarray
			if content.has("Assets"):
				for n in content["Assets"].keys():
					for x in content["Assets"][n].keys():
						
						if content["Assets"][n][x].has("Path"):
							content["Assets"][n][x]["Path"] = i.rstrip("Mod.json")+content["Assets"][n][x]["Path"]
						if content["Assets"][n][x].has("Server_Path"):
							content["Assets"][n][x]["Server_Path"] = i.rstrip("Mod.json")+content["Assets"][n][x]["Server_Path"]
						if content["Assets"][n][x].has("Client_Path"):
							content["Assets"][n][x]["Client_Path"] = i.rstrip("Mod.json")+content["Assets"][n][x]["Client_Path"]
						if content["Assets"][n][x].has("Image_Preview"):
							content["Assets"][n][x]["Image_Preview"] = i.rstrip("Mod.json")+content["Assets"][n][x]["Image_Preview"]
						if content["Assets"][n][x].has("Tag"):
							if !assets_tagged.has(content["Assets"][n][x]["Tag"]) :
								assets_tagged[content["Assets"][n][x]["Tag"]] = []
							assets_tagged[content["Assets"][n][x]["Tag"]].append(content["ModID"]+"/"+x)
						#print(content["Assets"][n][x])
				assets[content["ModID"]] = content["Assets"]
				
				if content["Assets"].has("Override_Binds") && content["ModID"] == "CoreAssets":
					if content["Assets"]["Override_Binds"].has("V3"):
						for xc in content["Assets"]["Override_Binds"]["V3"].keys():
							if !assets_tagged.has(xc):
								#print(content["Assets"]["Override_Binds"]["V3"][xc])
								assets_tagged[xc] = content["Assets"]["Override_Binds"]["V3"][xc]
		
		else:
			if content.has("ModID"):
				print("Error: Conflicting Mod ID:"+content["ModID"])
			else:
				print("Error: Error Invalid Mod")
	#if assets_tagged.has("Network_Command"):
		#print(assets_tagged["Network_Command"])
		
	call_deferred("emit_signal","load_finished")

func load_mod_assets() -> void:
	for i in assets.keys():
		for x in assets[i].keys():
			for y in assets[i][x]:
				if assets[i][x][y].has("Path"):
					if compiled_assets.keys().has(assets[i][x][y]["Path"]):
						assets[i][x][y]["Node"] = compiled_assets[assets[i][x][y]["Path"]]
					else:
						if x != "Scripts" && x != "Network_Commands" && x != "Characters":
							compiled_assets[assets[i][x][y]["Path"]] = load(assets[i][x][y]["Path"]).instantiate()
							assets[i][x][y]["Node"] = compiled_assets[assets[i][x][y]["Path"]]
						
	call_deferred("emit_signal","load_finished")

func find_script(ID:String, ApplyNode:Node2D, ParentNode:Node2D) -> void:
	var path = ""
	var AssetParts = ID.split("/")
	if assets.has(AssetParts[0]) &&\
		assets[AssetParts[0]].has("Scripts") &&\
		assets[AssetParts[0]]["Scripts"].has(AssetParts[1]) &&\
		assets[AssetParts[0]]["Scripts"][AssetParts[1]].has("Path"):
			ApplyNode.set_script(load(assets[AssetParts[0]]["Scripts"][AssetParts[1]]["Path"]))
			ApplyNode.name = AssetParts[1]

func find_animation(ID:String, ApplyNode:Node2D) -> void:
	var path = ""
	var AssetParts = ID.split("/")
	if assets.has(AssetParts[0]) &&\
		assets[AssetParts[0]].has("Animations") &&\
		assets[AssetParts[0]]["Animations"].has(AssetParts[1]) &&\
		assets[AssetParts[0]]["Animations"][AssetParts[1]].has("Node"):
			ApplyNode.add_child(assets[AssetParts[0]]["Animations"][AssetParts[1]]["Node"].duplicate())

func find_map(ID:String) -> Dictionary:
	var path = ""
	var AssetParts = ID.split("/")
	if assets.has(AssetParts[0]) &&\
		assets[AssetParts[0]].has("Maps") &&\
		assets[AssetParts[0]]["Maps"].has(AssetParts[1]):
			return assets[AssetParts[0]]["Maps"][AssetParts[1]]
	
	return {}

func find_log(ID:String) -> Dictionary:
	var path = ""
	var AssetParts = ID.split("/")
	if assets.has(AssetParts[0]) &&\
		assets[AssetParts[0]].has("Devlog_Entries") &&\
		assets[AssetParts[0]]["Devlog_Entries"].has(AssetParts[1]):
			return assets[AssetParts[0]]["Devlog_Entries"][AssetParts[1]]
	
	return {}

func find_asset(ID:String) -> Dictionary:
	var path = ""
	var AssetParts = ID.split("/")
	if assets.has(AssetParts[0]) &&\
		assets[AssetParts[0]].has("Models") &&\
		assets[AssetParts[0]]["Models"].has(AssetParts[1]):
			return assets[AssetParts[0]]["Models"][AssetParts[1]]
	
	return {}

func find_command(ID:String) -> Dictionary:
	var path = ""
	var AssetParts = ID.split("/")
	if assets.has(AssetParts[0]) &&\
		assets[AssetParts[0]].has("Network_Commands") &&\
		assets[AssetParts[0]]["Network_Commands"].has(AssetParts[1]):
			return assets[AssetParts[0]]["Network_Commands"][AssetParts[1]]
	
	return {}
	
func find_character(ID:String, ApplyNode:Sprite2D) -> void:
	var path = ""
	var AssetParts = ID.split("/")
	if assets.has(AssetParts[0]) &&\
		assets[AssetParts[0]].has("Characters") &&\
		assets[AssetParts[0]]["Characters"].has(AssetParts[1]):
			ApplyNode.texture = load(assets[AssetParts[0]]["Characters"][AssetParts[1]]["Path"])
