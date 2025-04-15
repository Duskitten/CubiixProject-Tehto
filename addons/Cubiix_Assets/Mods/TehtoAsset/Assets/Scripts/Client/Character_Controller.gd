extends Node2D

var move_dir:Vector2i = Vector2i.ZERO
var last_dir:String = "Down"

var Anim = ""
var Anim_New = ""
var Anim_Player = null
var astar_grid = AStarGrid2D.new()
var pointlist:Array
var active_point:Vector2 = Vector2.ZERO

func _ready() -> void:
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	astar_grid.cell_shape = AStarGrid2D.CELL_SHAPE_SQUARE
	astar_grid.region = Rect2i(0, 0, 160, 160)
	astar_grid.cell_size = Vector2(32, 32)
	astar_grid.update()
	active_point = (get_parent().global_position/32).round() *32
#	print(active_point)

func _process(delta: float) -> void:
	var compiledtext = ""
	#move_dir.x = Input.get_action_raw_strength("Right") - Input.get_action_raw_strength("Left")
	#move_dir.y = Input.get_action_raw_strength("Down") -  Input.get_action_raw_strength("Up") 
	
	if move_dir.y < 0:
		compiledtext += "Up"
	elif move_dir.y > 0:
		compiledtext += "Down"
	
	if move_dir.x < 0:
		compiledtext += "Left"
	elif move_dir.x > 0:
		compiledtext += "Right"
		
	if compiledtext != "":
		last_dir = compiledtext

	var fullcompile = ""
	if move_dir != Vector2i.ZERO:
		fullcompile = "Walk_"
	else:
		fullcompile = "Idle_"
		
	
	Anim_New = fullcompile + last_dir
	
	if Anim_Player == null:
		Anim_Player = get_parent().Hub.get_node_or_null("AnimationPlayer")
	else:
		if Anim != Anim_New:
			Anim = Anim_New
			Anim_Player.play(Anim)
			
	if Input.is_action_just_pressed("lmb"):
		var path = astar_grid.get_point_path(Vector2i((active_point/32).round()), Vector2i((get_global_mouse_position()/32).round()))
		get_parent().get_parent().get_node("Line2D").points = path
		pointlist = Array(path)
		pointlist.pop_front()
			
func _physics_process(delta: float) -> void:
	if active_point != null:
		if active_point.distance_to(get_parent().global_position) > 0.01:
			get_parent().global_position = get_parent().global_position.move_toward(active_point,2)
			if get_parent().global_position.direction_to(active_point).round() != Vector2.ZERO && pointlist.size() >= 0:
				move_dir = get_parent().global_position.direction_to(active_point).round()
		else:
			if pointlist.size() > 0:
				active_point = pointlist.pop_front()
			else:
				move_dir = Vector2i.ZERO
func move_to_point(point) -> void:
	pass
