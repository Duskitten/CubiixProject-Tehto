extends Node2D

var current_character = ""
var queued_character = []
func _ready() -> void:
	$Character_Texture/AnimationPlayer.animation_finished.connect(set_char.bind())

func change_character(Character:Texture, ID:String) -> void:
	if !$Character_Texture/AnimationPlayer.is_playing():
		print("Boop?")
		($Character_Texture.material as ShaderMaterial).set_shader_parameter("character_b", Character)
		$Character_Texture/AnimationPlayer.play("new_animation")
		current_character = ID
	else:
		print("Boop2?")
		queued_character.append([Character,ID])
	
func set_char(Anim:String) -> void:
	($Character_Texture.material as ShaderMaterial).set_shader_parameter("character_a", ($Character_Texture.material as ShaderMaterial).get_shader_parameter("character_b"))
	if queued_character.size() > 0:
		var popped = queued_character.pop_front()
		change_character(popped[0], popped[1])
