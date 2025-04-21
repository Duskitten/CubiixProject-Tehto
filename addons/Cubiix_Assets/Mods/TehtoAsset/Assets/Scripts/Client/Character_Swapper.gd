extends Node
@onready var Core = get_node("/root/Main_Scene/CoreLoader")

var Tick_Prev = 0
var Tick_Timer = 0
var serial = Serial.new()


func setup_device() -> bool:
	var exists = false
	var portname = ""
	for i in Serial.list_ports():
		if i.has("product") && i["product"] == "Tehto_Hub":
			exists = true
			portname = i["name"]
			break
	
	if exists:
		if !serial.is_open():
			serial.open(portname,115200)
	else:
		if serial.is_open():
			serial.close()

	return exists

func _process(delta: float) -> void:
	var Delta = Time.get_ticks_msec() - Tick_Prev
	Tick_Prev = Time.get_ticks_msec()
	Tick_Timer += Delta
	
	if Tick_Timer > 1000/20:
		if setup_device():
			if serial.available():
				var string:String = serial.read_str(true).trim_suffix("\r\n")
				if string != "":
					find_parent("Player").update_character(string)
